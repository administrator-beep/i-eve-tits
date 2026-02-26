import React, { useState } from 'react'

export function AssetsView({ characterId }) {
  const [assets, setAssets] = useState([])
  const [loading, setLoading] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const r = await fetch(`/data/assets/${characterId}`)
      const j = await r.json()
      setAssets(j.assets || [])
    } catch (e) {
      alert('Error: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{marginTop:20}}>
      <h3>Assets</h3>
      <button onClick={load}>{loading ? 'Loading...' : 'Load Assets'}</button>
      <table style={{width:'100%',borderCollapse:'collapse',marginTop:12}}>
        <thead>
          <tr style={{background:'#1a1a2e', textAlign:'left'}}>
            <th style={{padding:8,border:'1px solid #444'}}>Type</th>
            <th style={{padding:8,border:'1px solid #444'}}>Type ID</th>
            <th style={{padding:8,border:'1px solid #444'}}>Qty</th>
            <th style={{padding:8,border:'1px solid #444'}}>Location ID</th>
            <th style={{padding:8,border:'1px solid #444'}}>Synced</th>
          </tr>
        </thead>
        <tbody>
          {assets.map(a => (
            <tr key={a.item_id} style={{background:'#0f0f14'}}>
              <td style={{padding:8,border:'1px solid #444'}}>{a.type_name || 'unknown'}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{a.type_id}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{a.quantity}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{a.location_id}</td>
              <td style={{padding:8,border:'1px solid #444',fontSize:11}}>{new Date(a.synced_at).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {assets.length === 0 && !loading && <p>No assets loaded</p>}
    </div>
  )
}
