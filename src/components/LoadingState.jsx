export default function LoadingState({ mode }) {
  const modeLabels = {
    standard: 'The Sovereign Physician',
    longevity: 'Longevity Scientist',
    toughlove: 'Tough Love Coach',
  }

  const phases = [
    'Analyzing biomarker patterns...',
    'Cross-referencing optimal performance ranges...',
    'Mapping regional dietary factors...',
    'Synthesizing longevity protocols...',
    'Generating your elite health blueprint...',
  ]

  return (
    <div className="card-gold p-8 text-center animate-fade-in">
      {/* Animated pulse ring */}
      <div className="relative inline-flex items-center justify-center mb-6">
        <div className="absolute w-20 h-20 rounded-full border-2 border-gold-500/20 animate-ping" />
        <div className="absolute w-16 h-16 rounded-full border border-gold-500/30 animate-pulse" />
        <div className="w-12 h-12 rounded-full bg-gold-500/10 border border-gold-500/40 flex items-center justify-center">
          <svg className="w-6 h-6 text-gold-400 animate-spin" style={{ animationDuration: '3s' }} viewBox="0 0 24 24" fill="none">
            <path
              d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        </div>
      </div>

      <h3 className="text-lg font-bold text-slate-100 mb-1">
        {modeLabels[mode] || 'Sovereign Physician'} is Analyzing
      </h3>
      <p className="text-sm text-slate-400 mb-6">
        Compiling your personalized elite health blueprint
      </p>

      {/* Scanning phases */}
      <div className="space-y-2 max-w-xs mx-auto">
        {phases.map((phase, i) => (
          <div
            key={phase}
            className="flex items-center gap-2 text-xs text-slate-500"
            style={{ animationDelay: `${i * 0.4}s` }}
          >
            <div
              className="w-1.5 h-1.5 rounded-full bg-gold-500 flex-shrink-0 animate-pulse"
              style={{ animationDelay: `${i * 0.4}s` }}
            />
            {phase}
          </div>
        ))}
      </div>

      <p className="mt-6 text-xs text-slate-600">
        Powered by OpenAI — gpt-4o
      </p>
    </div>
  )
}
