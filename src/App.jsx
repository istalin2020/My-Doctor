import { useState } from 'react'
import Header from './components/Header'
import PatientIntake from './components/PatientIntake'
import LabsInput from './components/LabsInput'
import ModeSelector from './components/ModeSelector'
import LoadingState from './components/LoadingState'
import AnalysisReport from './components/AnalysisReport'
import { analyzePatient } from './services/api'

const TABS = [
  { id: 'profile', label: 'Patient Profile', icon: '👤' },
  { id: 'labs', label: 'Lab Reports', icon: '🔬' },
]

export default function App() {
  const [tab, setTab] = useState('profile')
  const [mode, setMode] = useState('standard')
  const [patientData, setPatientData] = useState({})
  const [labValues, setLabValues] = useState({})

  const [phase, setPhase] = useState('input') // 'input' | 'loading' | 'report'
  const [report, setReport] = useState('')
  const [isStreaming, setIsStreaming] = useState(false)
  const [error, setError] = useState(null)

  async function handleAnalyze() {
    setError(null)
    setReport('')
    setPhase('loading')

    // brief pause so user sees loading state before streaming starts
    await new Promise((r) => setTimeout(r, 600))

    setPhase('report')
    setIsStreaming(true)

    await analyzePatient({
      patientData,
      labValues,
      mode,
      onChunk: (text) => setReport((prev) => prev + text),
      onDone: () => setIsStreaming(false),
      onError: (msg) => {
        setIsStreaming(false)
        setError(msg)
        setPhase('input')
      },
    })
  }

  function handleReset() {
    setPhase('input')
    setReport('')
    setError(null)
    setIsStreaming(false)
  }

  const hasMinimalData =
    (patientData.age && patientData.gender) ||
    Object.values(labValues).some((v) => v !== '' && v != null)

  return (
    <div className="min-h-screen">
      <Header />

      <main className="max-w-6xl mx-auto px-4 md:px-6 py-8 space-y-6">
        {/* Hero */}
        <div className="text-center pt-2 pb-4">
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-gold-500/10 border border-gold-500/30 text-gold-400 text-xs font-medium mb-4">
            <span className="w-1.5 h-1.5 rounded-full bg-gold-400" />
            Elite Concierge Medicine AI
          </div>
          <h2 className="text-3xl md:text-4xl font-bold text-slate-100 mb-3">
            Your{' '}
            <span className="gold-text">Sovereign Physician</span>
          </h2>
          <p className="text-slate-400 max-w-xl mx-auto text-sm leading-relaxed">
            Submit your medical records and labs. Receive a comprehensive,
            data-driven elite health optimization blueprint — calibrated to
            optimal ranges, not merely "normal" ones.
          </p>
        </div>

        {phase === 'loading' && <LoadingState mode={mode} />}

        {phase === 'report' && (
          <AnalysisReport
            report={report}
            isStreaming={isStreaming}
            onReset={handleReset}
          />
        )}

        {phase === 'input' && (
          <>
            {error && (
              <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-400 text-sm">
                <strong>Error:</strong> {error}
                {error.includes('OPENAI_API_KEY') && (
                  <p className="mt-1 text-xs text-red-400/70">
                    Create a <code className="bg-red-900/30 px-1 rounded">.env</code> file in the project root and add your{' '}
                    <code className="bg-red-900/30 px-1 rounded">OPENAI_API_KEY</code>.
                  </p>
                )}
              </div>
            )}

            {/* Mode selector */}
            <div className="card p-6">
              <ModeSelector value={mode} onChange={setMode} />
            </div>

            {/* Tab navigation */}
            <div className="card overflow-hidden">
              <div className="flex border-b border-slate-700/60">
                {TABS.map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setTab(t.id)}
                    className={`flex items-center gap-2 px-5 py-3.5 text-sm font-medium transition-all duration-150 ${
                      tab === t.id
                        ? 'text-gold-400 border-b-2 border-gold-500 bg-gold-500/5'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/30'
                    }`}
                  >
                    <span>{t.icon}</span>
                    {t.label}
                  </button>
                ))}
              </div>

              <div className="p-6">
                {tab === 'profile' && (
                  <PatientIntake data={patientData} onChange={setPatientData} />
                )}
                {tab === 'labs' && (
                  <LabsInput data={labValues} onChange={setLabValues} />
                )}
              </div>
            </div>

            {/* CTA */}
            <div className="flex flex-col items-center gap-3 pt-2 pb-8">
              <button
                onClick={handleAnalyze}
                disabled={!hasMinimalData}
                className="btn-gold text-base px-10 py-4 disabled:opacity-40 disabled:cursor-not-allowed disabled:scale-100 disabled:shadow-none"
              >
                Generate Elite Health Blueprint
              </button>
              {!hasMinimalData && (
                <p className="text-xs text-slate-500">
                  Enter at least your age & gender, or one lab value to proceed.
                </p>
              )}
              <p className="text-xs text-slate-600 max-w-md text-center">
                ⚠️ This AI analysis is for optimization guidance only. It does not replace in-person emergency medical care.
              </p>
            </div>
          </>
        )}
      </main>
    </div>
  )
}
