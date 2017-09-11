function PeakSearchSlots(audio, Fs, slot_time)
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
  psdmos = abs(spect);

  M = 10;
  filtered = zeros(slot_len, 2*num_slots);
  for i=1:slot_len
      for k=max(1,i-M):min(slot_len,i+M)
        filtered(i,:) = filtered(i,:) + psdmos(k,:);
      end
  end
  filtered = filtered/(2*M + 1);
  threshold = std(psdmos(74-M:74+M, :));
  
fprintf('Slot Frequency    Peak Value  Adjacent-Mean  Adjacent-Std       M+3S   Found  Smothed\n');

for slot = 1:num_slots;
  start = 70;
  stop = 78;
  [val, indx] = max(psdmos(start:stop, slot));
  fpk = freqs(start + indx - 1);
  m = mean(psdmos([40:65 85:100], slot));
  s = std(psdmos([40:65 85:100], slot));
  smooth_found = 3*threshold(slot) + filtered(74, slot) < psdmos(74,slot);
  fprintf('%i   %f       %f       %f     %f    %f    %i   %i\n', slot, fpk, val, ...
    m, s, m + 3*s, (val - (m + 3*s) > 0), smooth_found);
end

end