# 인간관계와 의사소통 웹 강의록

서울대학교 간호대학 2026-2학기 「인간관계와 의사소통」 강의 내용을 학생이 혼자 복습할 수 있도록 정리한 웹 강의록이다.

- 웹으로 보기: https://icedcoffeesunjoo.github.io/human-relations-communication/
- 담당: 장선주

## 구성

| 위치 | 내용 |
|---|---|
| `src/` | 주차별 원고(Markdown). `index.md`는 표지 |
| `docs/` | 완성된 웹페이지 (GitHub Pages가 이 폴더를 보여 준다) |
| `template.html`, `assets/style.css`, `details.lua` | 디자인 틀과 pandoc 필터 |
| `build.ps1` | `src/*.md`를 `docs/*.html`로 바꾸는 스크립트 |

## 고치고 다시 만들기

1. `src/`의 md 파일을 고친다.
2. PowerShell에서 `pwsh -File build.ps1`을 실행한다. [pandoc](https://pandoc.org/)이 필요하다.
3. 바뀐 파일을 커밋하고 올리면 웹페이지에 반영된다.

내용의 저작권은 저자에게 있다.
