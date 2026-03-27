/**
 * Streams the AI analysis from the backend.
 * Calls onChunk(text) for each streamed token, onDone() when complete,
 * and onError(message) on failure.
 */
export async function analyzePatient({ patientData, labValues, mode, onChunk, onDone, onError }) {
  try {
    const response = await fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ patientData, labValues, mode }),
    })

    if (!response.ok) {
      const err = await response.json().catch(() => ({ error: response.statusText }))
      onError(err.error || 'Server error')
      return
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() // keep incomplete line in buffer

      for (const line of lines) {
        if (!line.startsWith('data: ')) continue
        const data = line.slice(6).trim()

        if (data === '[DONE]') {
          onDone()
          return
        }

        try {
          const parsed = JSON.parse(data)
          if (parsed.error) {
            onError(parsed.error)
            return
          }
          if (parsed.text) {
            onChunk(parsed.text)
          }
        } catch {
          // ignore malformed SSE lines
        }
      }
    }

    onDone()
  } catch (err) {
    onError(err.message || 'Network error')
  }
}
