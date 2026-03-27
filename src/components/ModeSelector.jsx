const MODES = [
  {
    id: 'standard',
    label: 'Sovereign Physician',
    icon: '⚕️',
    description: 'Comprehensive 360° health optimization. Optimal ranges, regional nutrition, and performance protocols.',
    accent: 'gold',
  },
  {
    id: 'longevity',
    label: 'Longevity Scientist',
    icon: '🧬',
    description: 'Cellular health deep-dive. mTOR/AMPK, NAD+, telomere science, and bio-hacking protocols.',
    accent: 'indigo',
  },
  {
    id: 'toughlove',
    label: 'Tough Love Coach',
    icon: '🔥',
    description: 'Zero tolerance. Brutally honest assessment. Immediate lifestyle overhaul. No excuses.',
    accent: 'red',
  },
]

const accentClasses = {
  gold: {
    border: 'border-gold-500',
    bg: 'bg-gold-500/10',
    icon: 'bg-gold-500/20 text-gold-400',
    badge: 'bg-gold-500/20 text-gold-400 border-gold-500/40',
    check: 'bg-gold-500',
  },
  indigo: {
    border: 'border-indigo-500',
    bg: 'bg-indigo-500/10',
    icon: 'bg-indigo-500/20 text-indigo-400',
    badge: 'bg-indigo-500/20 text-indigo-400 border-indigo-500/40',
    check: 'bg-indigo-500',
  },
  red: {
    border: 'border-red-500',
    bg: 'bg-red-500/10',
    icon: 'bg-red-500/20 text-red-400',
    badge: 'bg-red-500/20 text-red-400 border-red-500/40',
    check: 'bg-red-500',
  },
}

export default function ModeSelector({ value, onChange }) {
  return (
    <div>
      <p className="label">Consultation Mode</p>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        {MODES.map((mode) => {
          const ac = accentClasses[mode.accent]
          const selected = value === mode.id
          return (
            <button
              key={mode.id}
              onClick={() => onChange(mode.id)}
              className={`relative text-left p-4 rounded-xl border transition-all duration-200 cursor-pointer ${
                selected
                  ? `${ac.border} ${ac.bg}`
                  : 'border-slate-700 bg-navy-900 hover:border-slate-500'
              }`}
            >
              {selected && (
                <span
                  className={`absolute top-3 right-3 w-4 h-4 rounded-full ${ac.check} flex items-center justify-center`}
                >
                  <svg className="w-2.5 h-2.5 text-white" viewBox="0 0 10 10" fill="none">
                    <path d="M2 5l2.5 2.5L8 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </span>
              )}
              <span className={`inline-flex items-center justify-center w-9 h-9 rounded-lg text-lg mb-3 ${ac.icon}`}>
                {mode.icon}
              </span>
              <p className="font-semibold text-slate-100 text-sm mb-1">{mode.label}</p>
              <p className="text-xs text-slate-400 leading-relaxed">{mode.description}</p>
            </button>
          )
        })}
      </div>
    </div>
  )
}
