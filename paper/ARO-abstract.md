Tinnitus affects over 50 million people in the U.S.,
a third of which experience functional cognitive impairment
and a substantial reduction in quality of life.
Primary treatments for tinnitus, e.g., sound therapy,
involve targeted exposure to external sounds
to attentuate the perception of the tinnitus percept.
Prognosis improves when the external sounds
are closely informed by the internal tinnitus experience
of the patient (e.g., the constituent frequencies of
the psychoacoustic tinnitus spectrum (PTS)).
Current methods rely on reductionist assumptions
concerning the nature of tinnitus percepts
(e.g., that they are pure tones or have small-width Gaussian spectra),
producing correspondingly biased or incomplete PTS representations.
We utilize a novel reverse correlation approach
to characterize the PTS more completely.
n=4 healthy control subjects performed an audio-matching
reverse correlation experiment.
Subjects performed 2000 trials in blocks of 100,
in which they listened to 0.5-sec sample tinnitus percepts
from the American Tinnitus Association (ATA),
followed by a 0.5-sec random noise stimulus.
The ATA target signals chosen were "buzzing" and "roaring"
with strongly differing spectral content.
Subjects responded, "yes", if the random noise stimulus
sounded like the target signal and "no" if not.
Responses were mapped to ones ("yes" -> 1) and negative ones ("no" -> -1)
and the PTS was reconstructed using two algorithms:
linear regression (LR) and compressed sensing (CS).
Compressed sensing is a recent advance in signal processing
which has gained broad recognition in medical imaging
due to its ability to reduce scan times
without sacrificing image quality or introducing bias.
The stimuli spectra were mapped to 100 mel-spaced frequency bins
and used to reconstruct a PTS estimate of the target ATA signal.
Pearson's correlation coefficient was used to evaluate
reconstruction quality with respect to the ATA tinnitus example.
For the "buzzing" ATA target signal,
the r^2 value for linear regression reconstruction
was 0.187 +/- 0.143, vs. compressed sensing reconstruction
at 0.359 +/- 0.229
and for the "roaring" ATA target signal,
the r^2 value for linear regression reconstruction was
0.300 +/- 0.090 vs. compressed sensing reconstruction at
0.447 +/- 0.060.
Additionally,
we demonstrated the test-retest reliability of our method
via a resynthesis experiment in which a subject
who has performed the task once
repeats it with their CS reconstruction being the target signal.
High r^2 values here (REPORT THEM!) demonstrate the reliability of the method.
In this work, we demonstrated the feasibility of reverse correlation
for unbiased, detailed reconstructions spectrally-rich target signals
representing unknown psychoacoustic tinnitus spectra
and conclude that the robustness of 1-bit compressed sensing
leads to an increase in reconstruction accuracy
in the same number of trials.
This work holds promise to improve outcomes for tinnitus patients
by providing a validated clinical assay
that can be used to accurately and efficiently characterize
the individualized perceptual experience of tinnitus.

