// app.js — lógica del reproductor
const audio = document.getElementById('audio');
const stationsList = document.getElementById('stations-list');
const stationNameEl = document.getElementById('station-name');
const nowPlayingEl = document.getElementById('now-playing');
const playPauseBtn = document.getElementById('play-pause');
const volumeEl = document.getElementById('volume');
const muteBtn = document.getElementById('mute');

let stations = [];
let currentIndex = -1;
let isMuted = false;

function loadStations(){
  fetch('stations.json')
    .then(r => r.json())
    .then(data => {
      stations = data.concat(loadCustomStations());
      renderStations();
    })
    .catch(err => {
      console.error('No se pudo cargar stations.json', err);
      stations = loadCustomStations();
      renderStations();
    });
}

function loadCustomStations(){
  try{
    const raw = localStorage.getItem('mi_radios_stations');
    return raw ? JSON.parse(raw) : [];
  }catch(e){return []}
}

function saveCustomStations(arr){
  localStorage.setItem('mi_radios_stations', JSON.stringify(arr));
}

function renderStations(){
  stationsList.innerHTML = '';
  stations.forEach((s, i) => {
    const li = document.createElement('li');
    li.className = 'station';
    li.tabIndex = 0;
    li.innerHTML = `<strong>${escapeHtml(s.name)}</strong><small>${escapeHtml(s.url)}</small>`;
    li.addEventListener('click', () => playStation(i));
    li.addEventListener('keypress', (e) => { if(e.key === 'Enter') playStation(i); });
    stationsList.appendChild(li);
  });
}

function escapeHtml(text){
  return text.replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[m]);
}

function playStation(index){
  const s = stations[index];
  if(!s) return;
  currentIndex = index;
  stationNameEl.textContent = s.name;
  nowPlayingEl.textContent = 'Conectando...';
  audio.src = s.url;
  audio.play().then(() => {
    playPauseBtn.textContent = '⏸';
    nowPlayingEl.textContent = 'Reproduciendo';
    setMediaSession(s);
  }).catch(err => {
    console.error('Error al reproducir', err);
    nowPlayingEl.textContent = 'Error al reproducir esta estación (ver consola).';
  });
}

function setMediaSession(station){
  if('mediaSession' in navigator){
    navigator.mediaSession.metadata = new MediaMetadata({
      title: station.name,
      artist: 'Radio online',
      album: ''
    });
    navigator.mediaSession.setActionHandler('play', () => audio.play());
    navigator.mediaSession.setActionHandler('pause', () => audio.pause());
  }
}

playPauseBtn.addEventListener('click', () => {
  if(audio.paused){
    if(currentIndex === -1 && stations.length) playStation(0);
    else audio.play();
    playPauseBtn.textContent = '⏸';
  }else{
    audio.pause();
    playPauseBtn.textContent = '▶︎';
  }
});

volumeEl.addEventListener('input', (e) => {
  audio.volume = parseFloat(e.target.value);
});

muteBtn.addEventListener('click', () => {
  isMuted = !isMuted;
  audio.muted = isMuted;
  muteBtn.textContent = isMuted ? '🔇' : '🔊';
});

audio.addEventListener('playing', () => {
  nowPlayingEl.textContent = 'Reproduciendo';
});

audio.addEventListener('pause', () => {
  nowPlayingEl.textContent = 'Pausado';
});

audio.addEventListener('error', (e) => {
  nowPlayingEl.textContent = 'Error de reproducción';
});

// Añadir estación
const addForm = document.getElementById('add-form');
addForm.addEventListener('submit', (e) => {
  e.preventDefault();
  const name = document.getElementById('new-name').value.trim();
  const url = document.getElementById('new-url').value.trim();
  if(!name || !url) return;
  const custom = loadCustomStations();
  custom.push({name, url});
  saveCustomStations(custom);
  stations.push({name, url});
  renderStations();
  addForm.reset();
});

// Guardar volumen en localStorage
volumeEl.addEventListener('change', () => {
  localStorage.setItem('mi_radio_volume', volumeEl.value);
});

function restoreSettings(){
  const v = localStorage.getItem('mi_radio_volume');
  if(v) { volumeEl.value = v; audio.volume = parseFloat(v); }
}

// util para navegar con teclado: focus al primer elemento
function init(){
  loadStations();
  restoreSettings();
}

init();