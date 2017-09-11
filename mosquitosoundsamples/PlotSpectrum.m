function PlotSpectrum(audio, Fs)
  NFFT = 2^nextpow2(size(audio, 1));
  freqs = Fs/NFFT*(0:(NFFT/2 - 1));
  spect = fft(audio, NFFT);
  psd = [spect(:,1).*conj(spect(:,1)) spect(:,2).*conj(spect(:,2))]/NFFT;
  figure,plot(freqs, 20.0*log10(psd(1:NFFT/2,1)), freqs, 20.0*log10(psd(1:NFFT/2,2)))
  xlabel('Frequency (Hz)');
  ylabel('PSD (dB)');