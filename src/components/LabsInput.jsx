const LAB_PANELS = [
  {
    panel: 'Glycemic Control',
    icon: '🩸',
    fields: [
      { key: 'Fasting Glucose', unit: 'mg/dL', placeholder: '95', optimal: '70–85 mg/dL' },
      { key: 'HbA1c', unit: '%', placeholder: '5.8', optimal: '< 5.4%' },
      { key: 'Fasting Insulin', unit: 'μIU/mL', placeholder: '8', optimal: '< 5 μIU/mL' },
      { key: 'HOMA-IR', unit: 'index', placeholder: '1.9', optimal: '< 1.0' },
    ],
  },
  {
    panel: 'Lipid Panel',
    icon: '🫀',
    fields: [
      { key: 'Total Cholesterol', unit: 'mg/dL', placeholder: '210', optimal: '< 180 mg/dL' },
      { key: 'LDL-C', unit: 'mg/dL', placeholder: '140', optimal: '< 70 mg/dL' },
      { key: 'HDL-C', unit: 'mg/dL', placeholder: '45', optimal: '> 60 mg/dL' },
      { key: 'Triglycerides', unit: 'mg/dL', placeholder: '160', optimal: '< 80 mg/dL' },
      { key: 'Lp(a)', unit: 'mg/dL', placeholder: '35', optimal: '< 30 mg/dL' },
      { key: 'ApoB', unit: 'mg/dL', placeholder: '100', optimal: '< 80 mg/dL' },
    ],
  },
  {
    panel: 'Complete Blood Count',
    icon: '🔬',
    fields: [
      { key: 'Hemoglobin', unit: 'g/dL', placeholder: '13.5', optimal: '14–17 g/dL (M) / 12–15 (F)' },
      { key: 'Hematocrit', unit: '%', placeholder: '42', optimal: '42–50% (M)' },
      { key: 'WBC', unit: '×10³/μL', placeholder: '7.2', optimal: '4.5–7.5 ×10³/μL' },
      { key: 'Platelets', unit: '×10³/μL', placeholder: '220', optimal: '150–350 ×10³/μL' },
      { key: 'MCV', unit: 'fL', placeholder: '86', optimal: '85–95 fL' },
    ],
  },
  {
    panel: 'Metabolic Panel',
    icon: '🏥',
    fields: [
      { key: 'ALT (SGPT)', unit: 'U/L', placeholder: '35', optimal: '< 25 U/L' },
      { key: 'AST (SGOT)', unit: 'U/L', placeholder: '28', optimal: '< 25 U/L' },
      { key: 'GGT', unit: 'U/L', placeholder: '40', optimal: '< 25 U/L' },
      { key: 'Creatinine', unit: 'mg/dL', placeholder: '1.0', optimal: '0.8–1.1 mg/dL' },
      { key: 'eGFR', unit: 'mL/min', placeholder: '85', optimal: '> 90 mL/min' },
      { key: 'Uric Acid', unit: 'mg/dL', placeholder: '6.5', optimal: '< 5.5 mg/dL' },
    ],
  },
  {
    panel: 'Thyroid Function',
    icon: '🦋',
    fields: [
      { key: 'TSH', unit: 'mIU/L', placeholder: '2.8', optimal: '1.0–2.0 mIU/L' },
      { key: 'Free T3', unit: 'pg/mL', placeholder: '2.9', optimal: '3.2–4.2 pg/mL' },
      { key: 'Free T4', unit: 'ng/dL', placeholder: '1.1', optimal: '1.0–1.5 ng/dL' },
      { key: 'Anti-TPO Antibodies', unit: 'IU/mL', placeholder: '12', optimal: '< 35 IU/mL' },
    ],
  },
  {
    panel: 'Hormones',
    icon: '⚡',
    fields: [
      { key: 'Total Testosterone', unit: 'ng/dL', placeholder: '480', optimal: '700–1000 ng/dL (M)' },
      { key: 'Free Testosterone', unit: 'pg/mL', placeholder: '12', optimal: '15–25 pg/mL (M)' },
      { key: 'DHEA-S', unit: 'μg/dL', placeholder: '180', optimal: '200–350 μg/dL' },
      { key: 'Cortisol (AM)', unit: 'μg/dL', placeholder: '18', optimal: '10–20 μg/dL (AM)' },
      { key: 'Estradiol (E2)', unit: 'pg/mL', placeholder: '30', optimal: '20–40 pg/mL (M)' },
      { key: 'IGF-1', unit: 'ng/mL', placeholder: '160', optimal: '150–250 ng/mL' },
    ],
  },
  {
    panel: 'Vitamins & Minerals',
    icon: '💊',
    fields: [
      { key: 'Vitamin D (25-OH)', unit: 'ng/mL', placeholder: '22', optimal: '60–80 ng/mL' },
      { key: 'Vitamin B12', unit: 'pg/mL', placeholder: '380', optimal: '600–900 pg/mL' },
      { key: 'Folate', unit: 'ng/mL', placeholder: '8', optimal: '> 15 ng/mL' },
      { key: 'Ferritin', unit: 'ng/mL', placeholder: '25', optimal: '70–150 ng/mL (M)' },
      { key: 'Serum Iron', unit: 'μg/dL', placeholder: '90', optimal: '80–140 μg/dL' },
      { key: 'Magnesium (RBC)', unit: 'mg/dL', placeholder: '4.2', optimal: '5.2–6.5 mg/dL' },
      { key: 'Zinc', unit: 'μg/dL', placeholder: '70', optimal: '80–120 μg/dL' },
    ],
  },
  {
    panel: 'Inflammation & Longevity',
    icon: '🧬',
    fields: [
      { key: 'hsCRP', unit: 'mg/L', placeholder: '2.1', optimal: '< 0.5 mg/L' },
      { key: 'Homocysteine', unit: 'μmol/L', placeholder: '14', optimal: '< 7 μmol/L' },
      { key: 'ESR', unit: 'mm/hr', placeholder: '18', optimal: '< 10 mm/hr' },
      { key: 'Fibrinogen', unit: 'mg/dL', placeholder: '320', optimal: '< 250 mg/dL' },
    ],
  },
]

export default function LabsInput({ data, onChange }) {
  function update(key, value) {
    onChange({ ...data, [key]: value })
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start gap-3 p-3 rounded-xl bg-gold-500/8 border border-gold-500/20">
        <span className="text-gold-400 text-sm mt-0.5">💡</span>
        <p className="text-xs text-slate-400 leading-relaxed">
          Enter the values from your most recent lab report. Leave fields blank if not tested.
          The Sovereign Physician evaluates against <span className="text-gold-400 font-medium">optimal performance ranges</span>, not just "normal" reference ranges.
        </p>
      </div>

      {LAB_PANELS.map(({ panel, icon, fields }) => (
        <div key={panel}>
          <p className="section-title">
            <span>{icon}</span> {panel}
          </p>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {fields.map(({ key, unit, placeholder, optimal }) => (
              <div key={key}>
                <label className="label flex justify-between">
                  <span>{key}</span>
                  <span className="text-slate-600 normal-case font-normal">{unit}</span>
                </label>
                <div className="relative">
                  <input
                    className="input-field pr-12 text-sm"
                    type="number"
                    step="any"
                    placeholder={placeholder}
                    value={data[key] || ''}
                    onChange={(e) => update(key, e.target.value)}
                  />
                </div>
                <p className="text-slate-600 text-xs mt-1">Optimal: {optimal}</p>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}
