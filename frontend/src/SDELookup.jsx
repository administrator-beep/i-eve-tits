import React, { useState } from 'react'

export function SDELookup() {
  const [typeId, setTypeId] = useState('')
  const [typeData, setTypeData] = useState(null)
  const [loading, setLoading] = useState(false)

  const lookup = async () => {
    if (!typeId) return alert('Enter a type ID')
    setLoading(true)
    try {
      const r = await fetch(`/data/sde-type/${typeId}`)
      if (!r.ok) throw new Error('Type not found')
      const j = await r.json()
      setTypeData(j)
    } catch (e) {
      alert('Error: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{marginTop:20}}>
      <h3>SDE Type Lookup</h3>
      <div style={{display:'flex',gap:8}}>
        <input placeholder="Type ID" value={typeId} onChange={e=>setTypeId(e.target.value)} />
        <button onClick={lookup}>{loading ? 'Loading...' : 'Lookup'}</button>
      </div>
      {typeData && (
        <div style={{background:'#1a1a2e',padding:12,marginTop:12,borderRadius:4}}>
          <p><strong>Name:</strong> {typeData.name}</p>
          <p><strong>Type ID:</strong> {typeData.type_id}</p>
          <p><strong>Group ID:</strong> {typeData.group_id}</p>
          <p><strong>Volume:</strong> {typeData.volume}</p>
          <p><strong>Base Price:</strong> {typeData.base_price}</p>
        </div>
      )}
    </div>
  )
}
