module.exports = (req, res) => {
    // console.log(req);
    res.send(`
Markdown is a lightweight markup language for creating formatted text using a plain-text editor. It is designed to be easy to write and read. Here's a comprehensive guide on common markdown syntax.

1. Headings:

Use the \`#\` sign to denote headings. The number of \`#\` indicates the heading level. For example:

\`\`\`markdown
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
\`\`\`

2. Emphasis:

Use \`*\` or \`_\` to italicize text and \`**\` or \`__\` to make text bold.

\`\`\`markdown
*Italic text*
_Italic text_

**Bold text**
__Bold text__
\`\`\`

3. Lists:

Use \`*\`, \`+\`, or \`-\` to denote an unordered list. For an ordered list, use numbers.

\`\`\`markdown
Unordered:

* Item 1
* Item 2
    * Sub Item 2.1
    * Sub Item 2.2

Ordered:

1. First
2. Second
3. Third
\`\`\`

4. Links:

Use the following format \`[text](url)\` to insert hyperlinks.

\`\`\`markdown
[Visit Google](http://www.google.com)
\`\`\`

5. Images:

Similar to links, but prepend it with \`!\`.

\`\`\`markdown
![Image Description](image-url)
\`\`\`

6. Blockquotes:

Use \`>\` to denote a blockquote.

\`\`\`markdown
> This is a quote.
\`\`\`

7. Code:

Use back-ticks (\`). Use single back-ticks to denote inline code. For multi-line code, wrap it with triple back-ticks. You can also specify the code language for syntax highlighting.

\`\`\`markdown
Inline \`code\` 

Multi-line code:

\`\`\`
print(&quot;Hello, World&quot;)
\`\`\`

Specifying language:

\`\`\`python
print(&quot;Hello, World&quot;)
\`\`\`
\`\`\`

8. Tables:

You can create simple tables by assembling a list of words and dividing them with hyphens \`-\` (for the first row), and separating each cell with a pipe \`|\`. 

\`\`\`markdown
| Header 1 | Header 2 |
| -------- | -------- |
| Cell 1   |  Cell 2  |
| Cell 3   |  Cell 4  |
\`\`\`

9. Horizontal Rule:

Use triple hyphens \`---\` or triple asterisks \`***\`.

\`\`\`markdown
---
\`\`\`

10. Escaping Characters:
   
If you want to treat a markdown special character as a regular one, you need to escape it using backslash '\\'.

\`\`\`markdown
\* This text won't be italic \*
\`\`\`

Remember, different platforms may support different subsets of Markdown syntax, so the specifics could change based on where you're planning to use it.
`);
}