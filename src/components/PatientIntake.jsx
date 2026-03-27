const CONDITIONS = [
  'Hypertension', 'Type 2 Diabetes', 'Pre-Diabetes', 'High Cholesterol',
  'Hypothyroidism', 'Hyperthyroidism', 'Heart Disease', 'Fatty Liver (NAFLD)',
  'PCOS', 'Sleep Apnea', 'Obesity', 'Anxiety / Depression',
  'Osteoporosis', 'Arthritis', 'Chronic Kidney Disease', 'Autoimmune Condition',
]

export default function PatientIntake({ data, onChange }) {
  function update(field, value) {
    onChange({ ...data, [field]: value })
  }

  function toggleCondition(condition) {
    const current = data.conditions || []
    const next = current.includes(condition)
      ? current.filter((c) => c !== condition)
      : [...current, condition]
    update('conditions', next)
  }

  return (
    <div className="space-y-6">
      {/* Basic Info */}
      <div>
        <p className="section-title">
          <span className="text-gold-500">👤</span> Patient Profile
        </p>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="col-span-2">
            <label className="label">Full Name</label>
            <input
              className="input-field"
              placeholder="e.g. Rahul Sharma"
              value={data.name || ''}
              onChange={(e) => update('name', e.target.value)}
            />
          </div>
          <div>
            <label className="label">Age</label>
            <input
              className="input-field"
              type="number"
              placeholder="45"
              value={data.age || ''}
              onChange={(e) => update('age', e.target.value)}
            />
          </div>
          <div>
            <label className="label">Gender</label>
            <select
              className="input-field"
              value={data.gender || ''}
              onChange={(e) => update('gender', e.target.value)}
            >
              <option value="">Select</option>
              <option>Male</option>
              <option>Female</option>
              <option>Other</option>
            </select>
          </div>
          <div>
            <label className="label">Height (cm)</label>
            <input
              className="input-field"
              type="number"
              placeholder="175"
              value={data.height || ''}
              onChange={(e) => update('height', e.target.value)}
            />
          </div>
          <div>
            <label className="label">Weight (kg)</label>
            <input
              className="input-field"
              type="number"
              placeholder="82"
              value={data.weight || ''}
              onChange={(e) => update('weight', e.target.value)}
            />
          </div>
          <div className="col-span-2">
            <label className="label">Dietary / Regional Background</label>
            <select
              className="input-field"
              value={data.region || ''}
              onChange={(e) => update('region', e.target.value)}
            >
              <option value="">Select region</option>
              <option value="Indian (Vegetarian)">Indian — Vegetarian</option>
              <option value="Indian (Non-Vegetarian)">Indian — Non-Vegetarian</option>
              <option value="Indian (Vegan)">Indian — Vegan</option>
              <option value="US-based (Standard American Diet)">US — Standard American Diet</option>
              <option value="US-based (Health-conscious)">US — Health-Conscious</option>
              <option value="Mediterranean">Mediterranean</option>
              <option value="Other / Mixed">Other / Mixed</option>
            </select>
          </div>
        </div>
      </div>

      {/* Chief Complaints */}
      <div>
        <label className="label">Chief Complaints & Performance Goals</label>
        <textarea
          className="input-field resize-none h-24"
          placeholder="e.g. Persistent fatigue, low energy after 3pm, want to optimize testosterone, reduce visceral fat, improve sleep quality, run a half-marathon by December..."
          value={data.chiefComplaints || ''}
          onChange={(e) => update('chiefComplaints', e.target.value)}
        />
      </div>

      {/* Medical Conditions */}
      <div>
        <label className="label">Active Medical Conditions (select all that apply)</label>
        <div className="flex flex-wrap gap-2 mt-1">
          {CONDITIONS.map((c) => {
            const selected = (data.conditions || []).includes(c)
            return (
              <button
                key={c}
                onClick={() => toggleCondition(c)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-all duration-150 ${
                  selected
                    ? 'bg-gold-500/15 border-gold-500/50 text-gold-400'
                    : 'bg-navy-900 border-slate-700 text-slate-400 hover:border-slate-500'
                }`}
              >
                {selected && '✓ '}
                {c}
              </button>
            )
          })}
        </div>
      </div>

      {/* Medications & History */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="label">Current Medications & Supplements</label>
          <textarea
            className="input-field resize-none h-24"
            placeholder="e.g. Metformin 500mg BD, Atorvastatin 10mg OD, Vitamin D 60K weekly..."
            value={data.medications || ''}
            onChange={(e) => update('medications', e.target.value)}
          />
        </div>
        <div>
          <label className="label">Family History</label>
          <textarea
            className="input-field resize-none h-24"
            placeholder="e.g. Father — heart attack at 55, Mother — Type 2 Diabetes, Paternal grandfather — stroke..."
            value={data.familyHistory || ''}
            onChange={(e) => update('familyHistory', e.target.value)}
          />
        </div>
      </div>

      {/* Lifestyle */}
      <div>
        <p className="section-title">
          <span className="text-gold-500">🌿</span> Lifestyle Assessment
        </p>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div>
            <label className="label">Smoking</label>
            <select
              className="input-field"
              value={data.smoking || ''}
              onChange={(e) => update('smoking', e.target.value)}
            >
              <option value="">Select</option>
              <option>Never</option>
              <option>Former (quit)</option>
              <option>Occasional</option>
              <option>Daily smoker</option>
            </select>
          </div>
          <div>
            <label className="label">Alcohol</label>
            <select
              className="input-field"
              value={data.alcohol || ''}
              onChange={(e) => update('alcohol', e.target.value)}
            >
              <option value="">Select</option>
              <option>None</option>
              <option>Occasional (social)</option>
              <option>Moderate (1–2/day)</option>
              <option>Heavy (3+/day)</option>
            </select>
          </div>
          <div>
            <label className="label">Sleep (hrs/night)</label>
            <input
              className="input-field"
              type="number"
              step="0.5"
              placeholder="6.5"
              value={data.sleepHours || ''}
              onChange={(e) => update('sleepHours', e.target.value)}
            />
          </div>
          <div>
            <label className="label">Activity Level</label>
            <select
              className="input-field"
              value={data.activityLevel || ''}
              onChange={(e) => update('activityLevel', e.target.value)}
            >
              <option value="">Select</option>
              <option>Sedentary (desk job, no exercise)</option>
              <option>Light (1–2 days/week)</option>
              <option>Moderate (3–4 days/week)</option>
              <option>Active (5+ days/week)</option>
              <option>Athlete / Daily training</option>
            </select>
          </div>
        </div>
      </div>

      <div>
        <label className="label">Allergies / Intolerances</label>
        <input
          className="input-field"
          placeholder="e.g. Penicillin allergy, lactose intolerant, gluten sensitivity..."
          value={data.allergies || ''}
          onChange={(e) => update('allergies', e.target.value)}
        />
      </div>
    </div>
  )
}
