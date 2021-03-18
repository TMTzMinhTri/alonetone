import { Controller } from 'stimulus'

// All variants of alonetone's javascript players extends this controller
export default class extends Controller {
  static targets = ['title', 'seekBarContainer', 'seekBarLoaded']

  play(e) {
    this.isPlaying = true
    this.element.classList.add('playing')
    this.playCallback(e)
  }

  pause() {
    this.isPlaying = false
    this.pauseCallback()
  }

  stop() {
    this.stopCallback()
  }

  registerListen() {
    // console.log("REGIIIISTERRRRRRRING")
    // Rails.ajax({
    //   url: '/listens',
    //   type: 'POST',
    //   data: `id=${this.data.get('id')}`,
    //   success() {
    //   },
    // })
  }

  seek(position) {
    const event = new CustomEvent('track:seek', { 'detail': { position } , 'bubbles': true })
    this.element.dispatchEvent(event)
  }
}