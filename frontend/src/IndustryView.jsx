import React, { useState } from 'react'

export function IndustryView({ characterId }) {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const r = await fetch(`/data/industry-jobs/${characterId}`)
      const j = await r.json()
      setJobs(j.jobs || [])
    } catch (e) {
      alert('Error: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{marginTop:20}}>
      <h3>Industry Jobs</h3>
      <button onClick={load}>{loading ? 'Loading...' : 'Load Jobs'}</button>
      <table style={{width:'100%',borderCollapse:'collapse',marginTop:12}}>
        <thead>
          <tr style={{background:'#1a1a2e', textAlign:'left'}}>
            <th style={{padding:8,border:'1px solid #444'}}>Product</th>
            <th style={{padding:8,border:'1px solid #444'}}>Type ID</th>
            <th style={{padding:8,border:'1px solid #444'}}>Status</th>
            <th style={{padding:8,border:'1px solid #444'}}>Output Loc</th>
            <th style={{padding:8,border:'1px solid #444'}}>Synced</th>
          </tr>
        </thead>
        <tbody>
          {jobs.map(j => (
            <tr key={j.job_id} style={{background:'#0f0f14'}}>
              <td style={{padding:8,border:'1px solid #444'}}>{j.type_name || 'unknown'}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{j.type_id}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{j.status}</td>
              <td style={{padding:8,border:'1px solid #444'}}>{j.output_location_id}</td>
              <td style={{padding:8,border:'1px solid #444',fontSize:11}}>{new Date(j.synced_at).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {jobs.length === 0 && !loading && <p>No jobs loaded</p>}
    </div>
  )
}
