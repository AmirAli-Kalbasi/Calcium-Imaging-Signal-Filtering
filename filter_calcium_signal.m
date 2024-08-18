function filtered_signals = filter_calcium_signal(signal_data, ref_signal, consider_peak, corr_window_size, peak_window_size, corr_threshold, fs, pattern_len)
    %% filter_calcium_signal: Filter calcium imaging signals based on correlation with a reference signal.
    %
    % This function filters calcium imaging data by comparing each cell's signal
    % to a reference signal (e.g., the best detected cell). The function
    % identifies correlated patterns and filters the signals accordingly.
    %
    % Inputs:
    %   signal_data       : Matrix of calcium signals (each row corresponds to a cell's signal).
    %   ref_signal        : The reference signal, typically from the best detected cell.
    %   consider_peak     : Boolean flag (1 or 0) to consider peaks in the filtering process (default = 1).
    %   corr_window_size  : Window size for correlation calculation (default = 40).
    %   peak_window_size  : Window size for peak detection (default = 10).
    %   corr_threshold    : Correlation threshold to determine significant correlation (default = 0.8).
    %   fs                : Sampling frequency of the calcium imaging data (default = 1000).
    %   pattern_len       : Length for pattern extraction and comparison (default = 50).
    %
    % Outputs:
    %   filtered_signals  : Matrix of filtered signals, same size as signal_data.
    
    arguments
        signal_data;               % Input signals matrix (each row is a cell's signal)
        ref_signal;                % Reference signal (best detected cell)
        consider_peak (1,1) {mustBeNumeric} = 1;
        corr_window_size (1,1) {mustBeNumeric} = 40;
        peak_window_size (1,1) {mustBeNumeric} = 10;
        corr_threshold (1,1) {mustBeNumeric} = 0.8;
        fs (1,1) {mustBeNumeric} = 1000;
        pattern_len (1,1) {mustBeNumeric} = 50;
    end
    
    %% Step 1: Extract pattern from the reference signal based on detected peaks
    [~, peak_indices_ref, ~] = pan_tompkin(ref_signal, fs, 0); % Detect peaks in the reference signal
    peak_indices_ref = peak_indices_ref(2:end); % Exclude the first peak if it's noise
    
    % Extract pattern around each detected peak in the reference signal
    pattern_matrix = zeros(length(peak_indices_ref), 2 * pattern_len + 1);
    for i = 1:length(peak_indices_ref)
        pattern_matrix(i, :) = ref_signal(peak_indices_ref(i) - pattern_len : peak_indices_ref(i) + pattern_len);
    end
    pattern_template = mean(pattern_matrix, 1); % Average pattern across all detected peaks
    
    %% Step 2: Detect peaks in the input signals and calculate correlation
    num_cells = size(signal_data, 1);
    filtered_signals = zeros(size(signal_data)); % Preallocate for efficiency
    
    for cell_idx = 1:num_cells
        current_signal = signal_data(cell_idx, :);
        
        % Detect peaks in the current signal
        [peak_amplitudes, ~, ~] = pan_tompkin(current_signal, fs, 0);
        peak_threshold = mean(peak_amplitudes); % Mean peak amplitude as threshold
        
        % Calculate correlation with the reference pattern
        corr_values = zeros(length(current_signal), 1);
        for i = pattern_len + 1 : length(current_signal) - pattern_len
            segment = current_signal(i - pattern_len : i + pattern_len);
            corr_matrix = corrcoef(segment, pattern_template);
            corr_values(i) = corr_matrix(2, 1);
        end
        
        % Threshold correlations and remove low-signal regions
        corr_values(corr_values < corr_threshold) = 0;
        corr_values(current_signal < 0.1) = 0;
        
        [peaks, locs] = findpeaks(corr_values); % Find peaks in the correlation signal
        
        %% Step 3: Apply filtering based on correlation and peak detection
        filtered_signal = zeros(length(current_signal), 1);
        if consider_peak == 1
            % Filter based on signal peaks
            high_peaks = current_signal > peak_threshold;
            high_peak_indices = find(high_peaks == 1);
            for i = 1:length(high_peak_indices)
                filtered_signal(max(high_peak_indices(i) - peak_window_size, 1):min(high_peak_indices(i) + peak_window_size, length(current_signal))) = 1;
            end
            % Filter based on correlation peaks
            for i = 1:length(peaks)
                filtered_signal(max(locs(i) - corr_window_size, 1):min(locs(i) + corr_window_size, length(current_signal))) = 1;
            end
            filtered_signal(filtered_signal == 0) = 0.001; % Retain a small baseline to prevent complete zeroing
        else
            % Filter only based on correlation peaks exceeding peak threshold
            for i = 1:length(peaks)
                if peaks(i) > peak_threshold
                    filtered_signal(max(locs(i) - corr_window_size, 1):min(locs(i) + corr_window_size, length(current_signal))) = 1;
                end
            end
        end
        
        % Apply the filtering to the current signal
        filtered_signals(cell_idx, :) = filtered_signal .* current_signal';
    end
end
