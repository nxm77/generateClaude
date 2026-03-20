Set-Location 'D:\project1'; claude -p "请对整个项目进行代码审查，输出完整 Markdown 报告，不要省略细节，不要尝试自己写文件" | Out-File -Encoding utf8 'project-code-review.md'

cd /d D:\project1 && chcp 65001 >nul && claude -p "请对整个项目进行代码审查，输出完整 Markdown 报告，不要省略细节，不要尝试自己写文件" > project-code-review.md

