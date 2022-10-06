# Characterizing Complex Tinnitus Sounds Using Reverse Correlation: A Feasibility Study

### Background
Tinnitus affects an estimated 25 million people in the U.S., a majority of whom experience associated functional cognitive impairment and reduction in quality of life.
Clinical practice guidelines for treating tinnitus recommend Sound Therapy and Cognitive Behavioral Therapy, both of which may involve targeted exposure to external sounds.
Critically, treatment outcomes have been shown to improve when the external sounds used in treatment are closely informed by the internal tinnitus experience of the patient – e.g., the constituent frequencies of the psychoacoustic tinnitus spectrum (PTS).
Current methods for characterizing tinnitus percepts (e.g., pitch matching methods), assume that the PTS has a simple structure, as in a pure tone or narrow-band noise.
However, evidence suggests that, for many patients, the PTS has a more intricate structure which cannot be characterized using existing methods.
The present work represents a proof-of-concept study for characterizing the PTS using Reverse Correlation, a method widely used in psychophysics for unconstrained characterization of complex internal percepts.

### Methods
Three (n=3) normal hearing subjects participated in each of two (2) Reverse Correlation experiments.
In each experiment, subjects performed 2000 trials (20 blocks x 100 trials/block), in which they listened to a target tinnitus-like sound followed by a random noise stimulus.
Subjects were asked to decide (i.e., “yes” or “no”) whether the target sound was present in the stimulus.
Target sounds included example tinnitus sounds maintained by the American Tinnitus Association (ATA), labeled as “roaring” (experiment 1) and “buzzing” (experiment 2) and chosen for their broad-band and sharply differing in spectral content.
Stimuli were constructed by randomly assigning power levels (-20dB or 0dB) to each of 100 Mel-spaced frequency bins between 0.1 to 20 kHz, and generating waveforms using the inverse Fourier transform.
The PTS was estimated using both a conventional linear regression (LR) approach and a recently-developed compressive sensing (CS) approach.
Pearson's correlation coefficient was used to evaluate reconstruction quality with respect to the ATA tinnitus example.

### Results
For experiment 1 ("roaring"),
the *r* values for LR reconstruction were:
0.57, 0.45, 0.62 for each subject respectively
(mean +/- st. dev., 0.54 +/- 0.09) (one-tailed t-test, p = 0.0081),
and the *r* values for CS reconstruction were:
0.64, 0.64, 0.72 (0.67 +/- 0.04) (one-tailed t-test, p = 0.0015).

For experiment 2 ("buzzing"),
the *r* values for LR reconstruction were:
0.22, 0.58, 0.42 (0.41 + 0.18) (one-tailed t-test, p = 0.0591),
and the *r* values for CS reconstruction were:
0.32, 0.73, 0.67 (0.57 +/- 0.22) (one-tailed t-test, p = 0.0476)

All *r* values were significant (p < 0.05).

### Conclusions
This work demonstrates the feasibility of using Reverse Correlation for characterizing spectrally-rich tinnitus-like sounds by accurate PTS estimation.
Further, results indicate that the approach involving CS allows for substantial efficiency improvements over conventional approaches, allowing for fewer required trials and shorter protocols.
The approach studied here holds promise as a behavioral assay that
could be used clinically to characterize tinnitus in patients with a wider variety of tinnitus experience.
Future work will focus on validating this approach directly in tinnitus patients.
