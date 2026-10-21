// Audio Synthesizer for Android Web Audio (Beeps, high pitch ticks, rest finish chimes)
class SoundFx {
  constructor() {
    this.ctx = null;
    this.muted = false;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playRepBeep() {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(880, this.ctx.currentTime); // A5
      osc.frequency.exponentialRampToValueAtTime(1174.66, this.ctx.currentTime + 0.12); // D6

      gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.15);

      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.16);

      // Trigger Android vibration if available
      if (navigator.vibrate) {
        navigator.vibrate(60);
      }
    } catch (e) {
      console.warn("Audio play error", e);
    }
  }

  playCadenceTick() {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(523.25, this.ctx.currentTime); // C5

      gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.05);

      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.06);
    } catch (e) {}
  }

  playSetCompleteBeep() {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    try {
      const notes = [659.25, 880, 1318.51]; // E5, A5, E6
      notes.forEach((freq, idx) => {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, this.ctx.currentTime + idx * 0.1);
        gain.gain.setValueAtTime(0.25, this.ctx.currentTime + idx * 0.1);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + idx * 0.1 + 0.2);
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start(this.ctx.currentTime + idx * 0.1);
        osc.stop(this.ctx.currentTime + idx * 0.1 + 0.22);
      });

      if (navigator.vibrate) {
        navigator.vibrate([100, 50, 150]);
      }
    } catch (e) {}
  }

  playRestCountdownBeep() {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    try {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(740, this.ctx.currentTime);
      gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.1);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.11);
      if (navigator.vibrate) {
        navigator.vibrate(40);
      }
    } catch (e) {}
  }
}

// Workout State Engine
const sound = new SoundFx();

const state = {
  config: {
    sets: 3,
    reps: 10,
    repDuration: 4, // 4s per rep
    restTime: 90,   // 90s rest
    prepTime: 3     // 3s get ready
  },
  workout: {
    isRunning: false,
    isPaused: false,
    currentSet: 1,
    currentRep: 0,
    phase: 'idle', // 'prep' | 'work' | 'rest' | 'finished'
    phaseElapsed: 0,
    totalElapsed: 0
  },
  timerId: null,
  lastTimestamp: null
};

// DOM references
const elements = {
  // Screens
  panelSetup: document.getElementById('panelSetup'),
  panelWorkout: document.getElementById('panelWorkout'),
  modalComplete: document.getElementById('modalComplete'),

  // Setup inputs
  valSets: document.getElementById('valSets'),
  valReps: document.getElementById('valReps'),
  valTempo: document.getElementById('valTempo'),
  valRest: document.getElementById('valRest'),
  btnStartWorkout: document.getElementById('btnStartWorkout'),

  // Workout live displays
  badgePhase: document.getElementById('badgePhase'),
  phaseIcon: document.getElementById('phaseIcon'),
  phaseLabelText: document.getElementById('phaseLabelText'),
  heroSubtitle: document.getElementById('heroSubtitle'),
  heroPrimary: document.getElementById('heroPrimary'),
  heroDetail: document.getElementById('heroDetail'),
  ringProgress: document.getElementById('ringProgress'),
  tempoBarFill: document.getElementById('tempoBarFill'),
  tempoBarLabel: document.getElementById('tempoBarLabel'),
  tempoSubText: document.getElementById('tempoSubText'),

  // Stats boxes
  statSet: document.getElementById('statSet'),
  statRep: document.getElementById('statRep'),
  statTotalTime: document.getElementById('statTotalTime'),

  // Controls
  btnPause: document.getElementById('btnPause'),
  btnPauseIcon: document.getElementById('btnPauseIcon'),
  btnPauseText: document.getElementById('btnPauseText'),
  btnSkip: document.getElementById('btnSkip'),
  btnStop: document.getElementById('btnStop'),

  // Summary
  sumSets: document.getElementById('sumSets'),
  sumReps: document.getElementById('sumReps'),
  sumDuration: document.getElementById('sumDuration'),
  btnDone: document.getElementById('btnDone'),

  // Top bar toggles
  btnSoundToggle: document.getElementById('btnSoundToggle'),
  soundIcon: document.getElementById('soundIcon'),
  toast: document.getElementById('toast')
};

// SVG Circle circumference for r=115
const CIRCUMFERENCE = 2 * Math.PI * 115;
elements.ringProgress.style.strokeDasharray = `${CIRCUMFERENCE} ${CIRCUMFERENCE}`;
elements.ringProgress.style.strokeDashoffset = 0;

// Setup step button listeners
function setupStepper(btnMinusId, btnPlusId, prop, min, max, step, displayEl, unit = '') {
  document.getElementById(btnMinusId).addEventListener('click', () => {
    if (state.config[prop] > min) {
      state.config[prop] -= step;
      displayEl.textContent = state.config[prop] + unit;
    }
  });
  document.getElementById(btnPlusId).addEventListener('click', () => {
    if (state.config[prop] < max) {
      state.config[prop] += step;
      displayEl.textContent = state.config[prop] + unit;
    }
  });
}

setupStepper('btnSetsMinus', 'btnSetsPlus', 'sets', 1, 30, 1, elements.valSets);
setupStepper('btnRepsMinus', 'btnRepsPlus', 'reps', 1, 100, 1, elements.valReps);
setupStepper('btnTempoMinus', 'btnTempoPlus', 'repDuration', 1, 30, 1, elements.valTempo, 's');
setupStepper('btnRestMinus', 'btnRestPlus', 'restTime', 5, 600, 5, elements.valRest, 's');

// Preset Chips
document.querySelectorAll('.chip').forEach((chip) => {
  chip.addEventListener('click', () => {
    document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
    chip.classList.add('active');

    const sets = parseInt(chip.dataset.sets, 10);
    const reps = parseInt(chip.dataset.reps, 10);
    const tempo = parseInt(chip.dataset.tempo, 10);
    const rest = parseInt(chip.dataset.rest, 10);

    state.config.sets = sets;
    state.config.reps = reps;
    state.config.repDuration = tempo;
    state.config.restTime = rest;

    elements.valSets.textContent = sets;
    elements.valReps.textContent = reps;
    elements.valTempo.textContent = tempo + 's';
    elements.valRest.textContent = rest + 's';
    showToast(`Loaded ${chip.textContent.trim()} preset`);
  });
});

// Toast Helper
function showToast(msg) {
  elements.toast.textContent = msg;
  elements.toast.classList.add('show');
  setTimeout(() => elements.toast.classList.remove('show'), 2000);
}

// Sound toggle
elements.btnSoundToggle.addEventListener('click', () => {
  sound.muted = !sound.muted;
  if (sound.muted) {
    elements.soundIcon.textContent = 'volume_off';
    elements.btnSoundToggle.classList.remove('active');
    showToast('Muted');
  } else {
    elements.soundIcon.textContent = 'volume_up';
    elements.btnSoundToggle.classList.add('active');
    sound.init();
    sound.playCadenceTick();
    showToast('Sound & Haptics ON');
  }
});

// Format MM:SS
function formatTime(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

// Wake Lock API to keep Android screen on during workout
let wakeLock = null;
async function requestWakeLock() {
  try {
    if ('wakeLock' in navigator) {
      wakeLock = await navigator.wakeLock.request('screen');
    }
  } catch (err) {
    console.log('Wake Lock request failed:', err);
  }
}

function releaseWakeLock() {
  if (wakeLock) {
    wakeLock.release().then(() => { wakeLock = null; });
  }
}

// Start Workout
elements.btnStartWorkout.addEventListener('click', () => {
  sound.init();
  requestWakeLock();
  state.workout.isRunning = true;
  state.workout.isPaused = false;
  state.workout.currentSet = 1;
  state.workout.currentRep = 0;
  state.workout.totalElapsed = 0;

  // Start with 3s prep
  enterPrepPhase();

  elements.panelSetup.classList.add('hidden');
  elements.panelWorkout.classList.remove('hidden');
  elements.modalComplete.classList.add('hidden');

  startTimerLoop();
});

function enterPrepPhase() {
  state.workout.phase = 'prep';
  state.workout.phaseElapsed = 0;

  elements.badgePhase.className = 'status-badge badge-prep';
  elements.phaseIcon.textContent = 'timelapse';
  elements.phaseLabelText.textContent = 'Get Ready';

  elements.heroSubtitle.textContent = 'Starting in';
  elements.heroPrimary.textContent = '3';
  elements.heroDetail.textContent = `Set 1 of ${state.config.sets}`;

  elements.ringProgress.classList.remove('rest-mode');
  elements.tempoBarLabel.textContent = 'Preparation';
  elements.tempoSubText.textContent = 'Prepare your grip & stance';

  updateStatsDisplay();
}

function enterWorkPhase() {
  state.workout.phase = 'work';
  state.workout.phaseElapsed = 0;
  state.workout.currentRep = 0;

  elements.badgePhase.className = 'status-badge badge-work';
  elements.phaseIcon.textContent = 'fitness_center';
  elements.phaseLabelText.textContent = `Set ${state.workout.currentSet} Active`;

  elements.heroSubtitle.textContent = 'Current Rep';
  elements.heroPrimary.textContent = '0';
  elements.heroDetail.textContent = `Target: ${state.config.reps} reps`;

  elements.ringProgress.classList.remove('rest-mode');
  elements.tempoBarLabel.textContent = 'Rep Cadence';

  sound.playRepBeep();
  updateStatsDisplay();
}

function enterRestPhase() {
  state.workout.phase = 'rest';
  state.workout.phaseElapsed = 0;

  elements.badgePhase.className = 'status-badge badge-rest';
  elements.phaseIcon.textContent = 'snooze';
  elements.phaseLabelText.textContent = 'Rest Interval';

  elements.heroSubtitle.textContent = 'Rest Remaining';
  elements.heroPrimary.textContent = formatTime(state.config.restTime);
  elements.heroDetail.textContent = `Next: Set ${state.workout.currentSet + 1}`;

  elements.ringProgress.classList.add('rest-mode');
  elements.tempoBarLabel.textContent = 'Resting';
  elements.tempoSubText.textContent = 'Deep breaths, catch your breath';

  sound.playSetCompleteBeep();
  updateStatsDisplay();
}

function finishWorkout() {
  stopTimerLoop();
  releaseWakeLock();
  state.workout.isRunning = false;
  state.workout.phase = 'finished';

  const totalRepsDone = (state.workout.currentSet) * state.config.reps;
  elements.sumSets.textContent = state.workout.currentSet;
  elements.sumReps.textContent = totalRepsDone;
  elements.sumDuration.textContent = formatTime(state.workout.totalElapsed);

  elements.modalComplete.classList.remove('hidden');
  sound.playSetCompleteBeep();
}

// Timer Engine Loop
function startTimerLoop() {
  state.lastTimestamp = performance.now();
  if (state.timerId) cancelAnimationFrame(state.timerId);

  function step(now) {
    if (!state.workout.isRunning) return;

    const delta = (now - state.lastTimestamp) / 1000;
    state.lastTimestamp = now;

    if (!state.workout.isPaused) {
      state.workout.totalElapsed += delta;
      updateEngine(delta);
    }

    state.timerId = requestAnimationFrame(step);
  }

  state.timerId = requestAnimationFrame(step);
}

function stopTimerLoop() {
  if (state.timerId) {
    cancelAnimationFrame(state.timerId);
    state.timerId = null;
  }
}

// Update State Machine
function updateEngine(delta) {
  state.workout.phaseElapsed += delta;

  if (state.workout.phase === 'prep') {
    const remaining = Math.max(0, state.config.prepTime - state.workout.phaseElapsed);
    const displaySec = Math.ceil(remaining);
    elements.heroPrimary.textContent = displaySec > 0 ? displaySec : 'GO!';

    const progress = (state.config.prepTime - remaining) / state.config.prepTime;
    setProgressRing(progress);
    elements.tempoBarFill.style.width = `${progress * 100}%`;

    if (remaining <= 0) {
      enterWorkPhase();
    }
  } else if (state.workout.phase === 'work') {
    const repDuration = state.config.repDuration; // e.g. 4 seconds
    const totalSetWorkTime = state.config.reps * repDuration;

    // Determine current rep number (1, 2, ... up to target)
    const exactReps = state.workout.phaseElapsed / repDuration;
    const repNumber = Math.min(state.config.reps, Math.floor(exactReps) + 1);

    // Rep transition sound & animation
    if (repNumber !== state.workout.currentRep && repNumber <= state.config.reps) {
      state.workout.currentRep = repNumber;
      elements.heroPrimary.textContent = repNumber;
      elements.heroPrimary.classList.add('rep-tick-anim');
      setTimeout(() => elements.heroPrimary.classList.remove('rep-tick-anim'), 250);
      sound.playRepBeep();
    }

    // Sub-rep second cadence ticker
    const repFraction = (state.workout.phaseElapsed % repDuration) / repDuration;
    const currentRepSec = Math.floor(state.workout.phaseElapsed % repDuration) + 1;
    elements.tempoSubText.textContent = `${(repDuration - (state.workout.phaseElapsed % repDuration)).toFixed(1)}s remaining in rep`;
    elements.tempoBarFill.style.width = `${repFraction * 100}%`;

    // Overal set progress ring
    const setProgress = Math.min(1, state.workout.phaseElapsed / totalSetWorkTime);
    setProgressRing(setProgress);

    // Check if set is complete
    if (state.workout.phaseElapsed >= totalSetWorkTime) {
      if (state.workout.currentSet < state.config.sets) {
        enterRestPhase();
      } else {
        finishWorkout();
      }
    }
  } else if (state.workout.phase === 'rest') {
    const remaining = Math.max(0, state.config.restTime - state.workout.phaseElapsed);
    elements.heroPrimary.textContent = formatTime(Math.ceil(remaining));

    const progress = (state.config.restTime - remaining) / state.config.restTime;
    setProgressRing(1 - progress); // countdown ring
    elements.tempoBarFill.style.width = `${(1 - progress) * 100}%`;
    elements.tempoSubText.textContent = `${Math.ceil(remaining)}s left`;

    // 3, 2, 1 warning beeps
    const secRemain = Math.ceil(remaining);
    if (secRemain <= 3 && secRemain > 0 && Math.abs(remaining - secRemain) < 0.05) {
      sound.playRestCountdownBeep();
    }

    if (remaining <= 0) {
      state.workout.currentSet++;
      enterWorkPhase();
    }
  }

  updateStatsDisplay();
}

function setProgressRing(fraction) {
  const offset = CIRCUMFERENCE - (fraction * CIRCUMFERENCE);
  elements.ringProgress.style.strokeDashoffset = offset;
}

function updateStatsDisplay() {
  elements.statSet.textContent = `${state.workout.currentSet}/${state.config.sets}`;
  elements.statRep.textContent = `${state.workout.currentRep}/${state.config.reps}`;
  elements.statTotalTime.textContent = formatTime(state.workout.totalElapsed);
}

// Pause / Resume Toggle
elements.btnPause.addEventListener('click', () => {
  state.workout.isPaused = !state.workout.isPaused;
  if (state.workout.isPaused) {
    elements.btnPauseIcon.textContent = 'play_arrow';
    elements.btnPauseText.textContent = 'Resume';
    elements.btnPause.style.background = 'var(--md-sys-color-primary)';
    elements.btnPause.style.color = 'var(--md-sys-color-on-primary)';
  } else {
    elements.btnPauseIcon.textContent = 'pause';
    elements.btnPauseText.textContent = 'Pause';
    elements.btnPause.style.background = '';
    elements.btnPause.style.color = '';
    state.lastTimestamp = performance.now();
  }
});

// Skip current phase
elements.btnSkip.addEventListener('click', () => {
  if (state.workout.phase === 'prep') {
    enterWorkPhase();
  } else if (state.workout.phase === 'work') {
    if (state.workout.currentSet < state.config.sets) {
      enterRestPhase();
    } else {
      finishWorkout();
    }
  } else if (state.workout.phase === 'rest') {
    state.workout.currentSet++;
    enterWorkPhase();
  }
});

// Stop / Exit
elements.btnStop.addEventListener('click', () => {
  if (confirm("End current workout?")) {
    resetToSetup();
  }
});

elements.btnDone.addEventListener('click', () => {
  resetToSetup();
});

function resetToSetup() {
  stopTimerLoop();
  releaseWakeLock();
  state.workout.isRunning = false;
  state.workout.isPaused = false;
  elements.panelWorkout.classList.add('hidden');
  elements.modalComplete.classList.add('hidden');
  elements.panelSetup.classList.remove('hidden');
  elements.btnPauseIcon.textContent = 'pause';
  elements.btnPauseText.textContent = 'Pause';
  elements.btnPause.style.background = '';
  elements.btnPause.style.color = '';
}

// Register service worker for offline Android app
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch(err => {
      console.log('SW registration failed:', err);
    });
  });
}
