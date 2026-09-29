/* Reobote Gestão — Service Worker
   Cuida APENAS dos arquivos do próprio site. Chamadas para fora
   (Supabase, CDN) passam direto: se forem interceptadas aqui, uma falha
   de rede acaba devolvendo o HTML da página no lugar da resposta da API. */
const CACHE='reobote-v2';
const ASSETS=['./','./index.html','./pedidos.html','./manifest.webmanifest',
              './assets/icon-192.png','./assets/icon-512.png'];

self.addEventListener('install',e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).catch(()=>{}));
  self.skipWaiting();
});
self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET') return;

  let u;
  try{ u=new URL(e.request.url); }catch(_){ return; }

  /* nada de outra origem passa por aqui — nem para cache, nem para fallback */
  if(u.origin!==self.location.origin) return;

  /* o catálogo do portal muda com frequência: sempre buscar antes */
  const semCache=u.pathname.endsWith('catalogo.json');

  e.respondWith(
    fetch(e.request).then(r=>{
      if(!semCache && r && r.ok && r.type==='basic'){
        const cp=r.clone();
        caches.open(CACHE).then(c=>c.put(e.request,cp)).catch(()=>{});
      }
      return r;
    }).catch(()=>caches.match(e.request).then(r=>{
      if(r) return r;
      /* só a navegação cai na página; um arquivo que falta não vira HTML */
      return e.request.mode==='navigate' ? caches.match('./index.html') : Response.error();
    }))
  );
});
