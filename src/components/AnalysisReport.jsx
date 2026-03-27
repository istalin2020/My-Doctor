import { useEffect, useRef } from 'react'

// Lightweight Markdown renderer — handles the specific subset the AI produces.
function renderMarkdown(text) {
  if (!text) return ''

  const lines = text.split('\n')
  const output = []
  let i = 0

  while (i < lines.length) {
    const line = lines[i]

    // H2
    if (line.startsWith('## ')) {
      output.push(`<h2>${escHtml(line.slice(3))}</h2>`)
      i++
      continue
    }

    // H3
    if (line.startsWith('### ')) {
      output.push(`<h3>${escHtml(line.slice(4))}</h3>`)
      i++
      continue
    }

    // Horizontal rule
    if (/^[-*_]{3,}$/.test(line.trim())) {
      output.push('<hr />')
      i++
      continue
    }

    // Unordered list
    if (/^[*\-•] /.test(line)) {
      const items = []
      while (i < lines.length && /^[*\-•] /.test(lines[i])) {
        items.push(`<li>${inlineFormat(lines[i].replace(/^[*\-•] /, ''))}</li>`)
        i++
      }
      output.push(`<ul>${items.join('')}</ul>`)
      continue
    }

    // Ordered list
    if (/^\d+\. /.test(line)) {
      const items = []
      while (i < lines.length && /^\d+\. /.test(lines[i])) {
        items.push(`<li>${inlineFormat(lines[i].replace(/^\d+\. /, ''))}</li>`)
        i++
      }
      output.push(`<ol>${items.join('')}</ol>`)
      continue
    }

    // Blockquote
    if (line.startsWith('> ')) {
      output.push(`<blockquote>${inlineFormat(line.slice(2))}</blockquote>`)
      i++
      continue
    }

    // Empty line
    if (line.trim() === '') {
      i++
      continue
    }

    // Paragraph
    output.push(`<p>${inlineFormat(line)}</p>`)
    i++
  }

  return output.join('\n')
}

function escHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function inlineFormat(text) {
  // Bold+italic
  text = text.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
  // Bold
  text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  // Italic
  text = text.replace(/\*(.+?)\*/g, '<em>$1</em>')
  // Inline code
  text = text.replace(/`(.+?)`/g, '<code>$1</code>')
  // Status badges — colour-code 🟢 🟡 🔴
  text = text.replace(/🟢\s*(OPTIMAL)/gi, '<span class="badge-optimal">🟢 $1</span>')
  text = text.replace(/🟡\s*(SUB-OPTIMAL|SUBOPTIMAL)/gi, '<span class="badge-suboptimal">🟡 $1</span>')
  text = text.replace(/🔴\s*(CRITICAL|ELEVATED|LOW)/gi, '<span class="badge-critical">🔴 $1</span>')

  return text
}

export default function AnalysisReport({ report, isStreaming, onReset }) {
  const bottomRef = useRef(null)
  const reportRef = useRef(null)

  // Auto-scroll while streaming
  useEffect(() => {
    if (isStreaming && bottomRef.current) {
      bottomRef.current.scrollIntoView({ behavior: 'smooth', block: 'end' })
    }
  }, [report, isStreaming])

  function handleCopy() {
    navigator.clipboard.writeText(report)
  }

  function handlePrint() {
    const win = window.open('', '_blank')
    win.document.write(`
      <html>
        <head>
          <title>My Doctor — Sovereign Physician Report</title>
          <style>
            body { font-family: Georgia, serif; max-width: 800px; margin: 40px auto; line-height: 1.7; color: #1a1a2e; }
            h2 { color: #8b6914; border-bottom: 1px solid #c9a227; padding-bottom: 8px; margin-top: 32px; }
            h3 { color: #333; margin-top: 20px; }
            strong { color: #111; }
            li { margin-bottom: 6px; }
            hr { border-color: #ddd; margin: 24px 0; }
            code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; font-family: monospace; }
            .badge-optimal { color: #059669; font-weight: bold; }
            .badge-suboptimal { color: #d97706; font-weight: bold; }
            .badge-critical { color: #dc2626; font-weight: bold; }
            blockquote { border-left: 3px solid #c9a227; padding-left: 16px; color: #555; font-style: italic; }
            @media print { body { margin: 20px; } }
          </style>
        </head>
        <body>
          <h1 style="color:#8b6914; text-align:center;">My Doctor — Sovereign Physician Report</h1>
          <p style="text-align:center; color:#888; font-size:0.85em;">Generated ${new Date().toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' })}</p>
          <hr/>
          ${renderMarkdown(report)}
        </body>
      </html>
    `)
    win.document.close()
    win.print()
  }

  return (
    <div className="animate-slide-up">
      {/* Toolbar */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-emerald-400" />
          <span className="text-sm font-medium text-slate-300">
            {isStreaming ? (
              <span className="flex items-center gap-2">
                <span className="text-gold-400">Receiving analysis</span>
                <span className="text-slate-500 text-xs animate-pulse">streaming...</span>
              </span>
            ) : (
              'Analysis Complete'
            )}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            disabled={isStreaming}
            className="btn-ghost text-xs px-3 py-1.5 disabled:opacity-40"
            title="Copy to clipboard"
          >
            Copy
          </button>
          <button
            onClick={handlePrint}
            disabled={isStreaming}
            className="btn-ghost text-xs px-3 py-1.5 disabled:opacity-40"
            title="Print / Save as PDF"
          >
            Print / PDF
          </button>
          <button
            onClick={onReset}
            className="btn-ghost text-xs px-3 py-1.5 text-gold-400 border-gold-600/40 hover:border-gold-500"
          >
            New Consultation
          </button>
        </div>
      </div>

      {/* Report card */}
      <div className="card-gold p-6 md:p-8">
        <div
          ref={reportRef}
          className={`report-content ${isStreaming ? 'typing-cursor' : ''}`}
          dangerouslySetInnerHTML={{ __html: renderMarkdown(report) }}
        />
        <div ref={bottomRef} />
      </div>
    </div>
  )
}
