"""Renders docs/roster_analysis.md as the page published to its artifact (the status has the
link), in the bible's style. Run from the repo root after the page changes:
    python3 tools/pages/roster_analysis_page.py > /tmp/roster_analysis.html
"""
import markdown, re, sys, pathlib
src = pathlib.Path('docs/roster_analysis.md').read_text()
body = markdown.markdown(src, extensions=['tables'])
body = body.replace('<table>', '<div class="tablewrap"><table>').replace('</table>', '</table></div>')
title = 'Riftgate Roster Analysis'
page = f"""<title>{title}</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
  /* Layout: one reading column in the bible's briefing style; wide tables scroll inside their own frame. */
  :root {{
    --ground: #F2F3F5; --surface: #FFFFFF; --ink: #1A1E25; --muted: #5C6673;
    --rule: #D5DAE1; --rule-strong: #B9C0CA; --accent: #B4501C; --steel: #2E5B87;
    --tint: #E9EBEF; --code-bg: #E6E9EE;
    --display: "Barlow Condensed", "Arial Narrow", Impact, sans-serif;
    --body: "IBM Plex Sans", "Helvetica Neue", Arial, sans-serif;
    --mono: "IBM Plex Mono", "SFMono-Regular", Menlo, monospace;
  }}
  @media (prefers-color-scheme: dark) {{
    :root:not([data-theme="light"]) {{
      --ground: #14171C; --surface: #1C2028; --ink: #E4E7EB; --muted: #97A1AD;
      --rule: #2E343D; --rule-strong: #414955; --accent: #E3894B; --steel: #7FAEDF;
      --tint: #232830; --code-bg: #262C35; color-scheme: dark;
    }}
  }}
  :root[data-theme="dark"] {{
    --ground: #14171C; --surface: #1C2028; --ink: #E4E7EB; --muted: #97A1AD;
    --rule: #2E343D; --rule-strong: #414955; --accent: #E3894B; --steel: #7FAEDF;
    --tint: #232830; --code-bg: #262C35; color-scheme: dark;
  }}
  * {{ box-sizing: border-box; }}
  body {{
    background: var(--ground); color: var(--ink); font-family: var(--body);
    font-size: 16px; line-height: 1.6; margin: 0;
    padding-left: max(16px, env(safe-area-inset-left, 0px));
    padding-right: max(16px, env(safe-area-inset-right, 0px));
    padding-block: 0 96px;
  }}
  .page {{ max-width: 76ch; margin: 0 auto; min-width: 0; }}
  h1, h2, h3, h4 {{ font-family: var(--display); text-wrap: balance; line-height: 1.05; margin: 0; letter-spacing: 0.005em; }}
  h1 {{ font-size: clamp(36px, 8vw, 60px); font-weight: 800; text-transform: uppercase; border-top: 6px solid var(--ink); padding-top: 28px; margin-top: 0; }}
  h2 {{ font-size: 30px; font-weight: 700; text-transform: uppercase; border-bottom: 2px solid var(--ink); padding-bottom: 8px; margin: 48px 0 18px; }}
  h3 {{ font-size: 22px; font-weight: 700; margin: 30px 0 10px; }}
  p {{ margin: 0 0 1em; max-width: 68ch; }}
  li {{ margin-bottom: 6px; }}
  ul, ol {{ padding-left: 1.3em; margin: 0 0 1em; }}
  a {{ color: var(--steel); }}
  strong {{ font-weight: 600; }}
  em {{ font-style: italic; }}
  code {{ font-family: var(--mono); background: var(--code-bg); padding: 1px 5px; font-size: 14px; }}
  .tablewrap {{ overflow-x: auto; margin: 12px 0 24px; border: 1px solid var(--rule-strong); background: var(--surface); }}
  table {{ border-collapse: collapse; width: 100%; font-size: 14px; min-width: 640px; }}
  thead th {{ text-align: left; font-family: var(--mono); font-size: 11px; letter-spacing: 0.1em; text-transform: uppercase; color: var(--muted); font-weight: 500; padding: 8px 10px; border-bottom: 2px solid var(--ink); }}
  tbody td {{ padding: 9px 10px; border-bottom: 1px solid var(--rule); vertical-align: top; min-width: 9em; }}
  tbody td:first-child {{ font-weight: 600; }}
  .stamp {{ font-family: var(--mono); font-size: 12px; letter-spacing: 0.12em; text-transform: uppercase; color: var(--muted); margin: 10px 0 24px; }}
  footer {{ border-top: 1px solid var(--rule-strong); padding-top: 16px; font-size: 13px; color: var(--muted); margin-top: 48px; }}
  a:focus-visible {{ outline: 2px solid var(--accent); outline-offset: 2px; }}
</style>
<div class="page">
{body}
<footer>Rendered from <code>docs/roster_analysis.md</code> on the branch <code>ccr-777fd46a-32dw2m</code>, 14 October 2026. The design record is the bible; this page is the analysis it points to, and retires to git once its decisions are rows and content.</footer>
</div>
"""
# a stamp line under the title
page = re.sub(r'(</h1>)', r'\1\n<p class="stamp">The roster analysis · 14 October 2026 · Claude\'s reading for Ryan to move</p>', page, count=1)
sys.stdout.write(page)
