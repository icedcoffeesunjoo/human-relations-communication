-- 웹 강의록 pandoc 필터
-- ::: more   → 접었다 펴는 <details> ("자세히 보기", label 속성으로 문구 변경)
-- ::: flow   → 번호 목록을 화살표로 잇는 흐름도. 항목: **제목** 설명
-- ::: rules  → 번호 목록을 원칙 카드로 (CSS만 적용)

local function inl_html(inlines)
  return pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "html"):gsub("\n$", "")
end

local function flow_html(el)
  local list
  for _, b in ipairs(el.content) do
    if b.t == "OrderedList" or b.t == "BulletList" then list = b break end
  end
  if not list then return nil end
  local cls = "flow"
  for _, c in ipairs(el.classes) do if c ~= "flow" then cls = cls .. " " .. c end end
  local out = { '<ol class="' .. cls .. '">' }
  for i, item in ipairs(list.content) do
    local inl = {}
    for _, blk in ipairs(item) do
      if blk.t == "Plain" or blk.t == "Para" then
        for _, x in ipairs(blk.content) do table.insert(inl, x) end
      end
    end
    local title, rest = nil, {}
    if inl[1] and inl[1].t == "Strong" then
      title = inl_html(inl[1].content)
      for j = 2, #inl do table.insert(rest, inl[j]) end
      while rest[1] and (rest[1].t == "Space" or rest[1].t == "SoftBreak") do table.remove(rest, 1) end
    else
      rest = inl
    end
    if i > 1 then table.insert(out, '<li class="edge" aria-hidden="true"></li>') end
    local node = '<li class="node">'
    if title then node = node .. "<b>" .. title .. "</b>" end
    if #rest > 0 then node = node .. "<span>" .. inl_html(rest) .. "</span>" end
    table.insert(out, node .. "</li>")
  end
  table.insert(out, "</ol>")
  local blocks = { pandoc.RawBlock("html", '<figure class="fig">' .. table.concat(out, "\n")) }
  -- 목록 밖의 문단은 그림 설명으로
  for _, b in ipairs(el.content) do
    if b ~= list and (b.t == "Para" or b.t == "Plain") then
      table.insert(blocks, pandoc.RawBlock("html", "<figcaption>" .. inl_html(b.content) .. "</figcaption>"))
    end
  end
  table.insert(blocks, pandoc.RawBlock("html", "</figure>"))
  return blocks
end

function Div(el)
  if el.classes:includes("more") then
    local label = el.attributes["label"] or "자세히 보기"
    local blocks = {
      pandoc.RawBlock("html", '<details class="more"><summary>' .. label .. '</summary><div class="more-body">')
    }
    for _, b in ipairs(el.content) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock("html", "</div></details>"))
    return blocks
  end
  if el.classes:includes("flow") then
    return flow_html(el)
  end
end

-- 표는 테두리 카드 안에
function Table(t)
  return { pandoc.RawBlock("html", '<div class="tbl">'), t, pandoc.RawBlock("html", "</div>") }
end
