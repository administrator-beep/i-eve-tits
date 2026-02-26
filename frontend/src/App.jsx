import React, {useEffect, useState} from 'react'
import { AssetsView } from './AssetsView'
import { IndustryView } from './IndustryView'
import { SDELookup } from './SDELookup'

export default function App(){
  const [overview, setOverview] = useState(null)
  const [tokenId, setTokenId] = useState('')
  const [jobStatus, setJobStatus] = useState(null)
  const [view, setView] = useState('home') // home, assets, industry, lookup

  useEffect(()=>{
    fetch('/dashboard/overview')
      .then(r=>r.json())
      .then(setOverview)
      .catch(()=>{})
  },[])

  const verify = async ()=>{
    if(!tokenId) return alert('enter token id')
    const r = await fetch(`/auth/verify/${tokenId}`)
    const j = await r.json()
    alert(JSON.stringify(j, null, 2))
  }

  const refresh = async ()=>{
    if(!tokenId) return alert('enter token id')
    const r = await fetch(`/auth/refresh/${tokenId}`, {method:'POST'})
    const j = await r.json()
    alert(JSON.stringify(j, null, 2))
  }

  const enqueueAssets = async ()=>{
    if(!tokenId) return alert('enter token id')
    const r = await fetch(`/sync/enqueue/assets/${tokenId}`, {method:'POST'})
    const j = await r.json()
    setJobStatus(j)
  }

  const characterId = overview?.mining_summary?.character_id || parseInt(tokenId) || null

  return (
    <div style={{fontFamily:'Inter, Arial, sans-serif',padding:20,background:'#0b0b0f',minHeight:'100vh',color:'#d7d7e0'}}>
      <h1>I-EVE-TITS</h1>
      <p>Industrial Eve Technology Information Tethering System</p>

      <div style={{display:'flex', gap:12, marginBottom:20}}>
        <button onClick={()=>setView('home')} style={{background:view==='home'?'#4a90ff':'#333'}}>Home</button>
        <button onClick={()=>setView('assets')} style={{background:view==='assets'?'#4a90ff':'#333'}}>Assets</button>
        <button onClick={()=>setView('industry')} style={{background:view==='industry'?'#4a90ff':'#333'}}>Industry</button>
        <button onClick={()=>setView('lookup')} style={{background:view==='lookup'?'#4a90ff':'#333'}}>SDE Lookup</button>
      </div>

      {view === 'home' && (
        <>
          <h2>Overview</h2>
          <pre style={{background:'#071021',padding:12}}>{overview?JSON.stringify(overview,null,2):'loading...'}</pre>

          <h2>Token actions</h2>
          <input placeholder="token id" value={tokenId} onChange={e=>setTokenId(e.target.value)} />
          <button onClick={verify}>Verify</button>
          <button onClick={refresh}>Refresh</button>
          <button onClick={enqueueAssets}>Enqueue assets sync</button>

          {jobStatus && <pre style={{background:'#071021',padding:12}}>{JSON.stringify(jobStatus,null,2)}</pre>}
        </>
      )}

      {view === 'assets' && characterId && <AssetsView characterId={characterId} />}
      {view === 'industry' && characterId && <IndustryView characterId={characterId} />}
      {view === 'lookup' && <SDELookup />}
    </div>
  )
}
