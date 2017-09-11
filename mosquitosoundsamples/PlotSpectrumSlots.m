function PlotSpectrumSlots(audio, Fs, slot_time)
  Ts = 1/Fs;
  slot_len = ceil(slot_time/Ts);
  num_slots = ceil(size(audio, 1) / slot_len);
  num_zeros_to_pad = num_slots*slot_len - size(audio, 1);
  audio = [audio; zeros(num_zeros_to_pad, 2)];
  audio_slots1 = reshape(audio(:, 1), slot_len, num_slots);
  audio_slots2 = reshape(audio(:, 2), slot_len, num_slots);
  audio_slots = [audio_slots1 audio_slots2];
  NFFT = 2^nextpow2(slot_len);
  freqs = Fs/NFFT*(0:(NFFT/2 - 1));
  spect = fft(repmat(hann(slot_len),1,2*num_slots).*audio_slots, NFFT);
  %psd = [spect(:,1).*conj(spect(:,1)) spect(:,2).*conj(spect(:,2))]/NFFT;
  psdmos = abs(spect);
  M = 10;
  filtered = zeros(slot_len, 2*num_slots);
  for i=1:slot_len
      for k=max(1,i-M):min(slot_len,i+M)
        filtered(i,:) = filtered(i,:) + psdmos(k,:);
      end
  end
  filtered = filtered/(2*M + 1);
  f = figure;
  %for i = 1:num_slots
  i = 1;
  
  while(i < num_slots)
    plot(freqs(1:200)/1000.0, psdmos(1:200,i),freqs(1:200)/1000.0, filtered(1:200, i)) %, freqs/1000.0, 20.0*log10(psd(1:NFFT/2,i + num_slots)))
    xlabel('Frequency (kHz)');
    ylabel('PSD (dB)');
    current_title = sprintf('Spectrum Slot %i out of %i', i, num_slots);
    title(current_title);
    waitforbuttonpress;
    kkey = get(gcf, 'CurrentCharacter');
    if (kkey == 'k') % || kkey == \24 || kkey == \27)
        if (i > 1)
            i = i - 1;
        end
    else
        if (kkey == 'q')
            break;
        else
            i = i + 1;
        end
    end
  end
end