;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Ben Woodcroft <b.woodcroft@uq.edu.au>
;;;
;;; This file is part of the Australian Centre for Ecogenomics' GNU Guix package
;;; repository.
;;;
;;; The repository is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; The repository is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;;; more details.
;;;
;;; You should have received a copy of the GNU General Public License along with
;;; the repository.  If not, see <http://www.gnu.org/licenses/>.




;;; This package seems to work, and could be submitted to guix-devel in future.
(define-public dirseq
  (package
    (name "dirseq")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (rubygems-uri "dirseq" version))
       (sha256
        (base32
         "1fixvy3zapl16x71nlsra2g1c3lgf220rmqs5d0llpcd0k4b7hjf"))))
    (build-system ruby-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'build 'patch-paths-to-inputs
           (lambda _
             (substitute* "bin/dirseq"
               (("\\\"sed") (string-append "\"" (which "sed")))
               (("\\\"samtools") (string-append "\"" (which "samtools")))
               (("\\\"bedtools") (string-append "\"" (which "bedtools"))))
             #t))
         ;; Call rspec directly so jeweler is not required.
         (replace 'check
           (lambda _
             (zero? (system* "rspec" "spec/script_spec.rb")))))))
    (native-inputs
     `(("ruby-rspec" ,ruby-rspec-2)))
    (inputs
     `(("bedtools" ,bedtools)
       ("samtools" ,samtools)))
    (propagated-inputs
     `(("bioruby" ,bioruby)
       ("ruby-bio-commandeer" ,ruby-bio-commandeer)
       ("ruby-bio-logger" ,ruby-bio-logger)))
    (synopsis "Gene expression calculator for metatranscriptomics")
    (description
     "Dirseq is a calculates gene expression metrics, aimed particularly at
metatranscriptomic data mapped to population genomes.  DirSeq works out whether
RNAseq reads from metatranscriptomes are generally in the same direction as the
ORF predicted and provide gene-wise coverages using DNAseq mappings.")
    (home-page "http://github.com/wwood/dirseq")
    (license license:expat)))

;;; Waiting to be pushed to guix alongside the OrfM update.
(define-public ruby-bio-commandeer
  (package
    (name "ruby-bio-commandeer")
    (version "0.1.2")
    (source
     (origin
       (method url-fetch)
       (uri (rubygems-uri "bio-commandeer" version))
       (sha256
        (base32
         "061jxa6km92qfwzl058r2gp8gfcsbyr7m643nw1pxvmjdswaf6ly"))))
    (build-system ruby-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           ;; Run test without calling 'rake' so that jeweler is
           ;; not required as an input.
           (lambda _
             (zero? (system* "rspec" "spec/bio-commandeer_spec.rb")))))))
    (propagated-inputs
     `(("ruby-bio-logger" ,ruby-bio-logger)
       ("ruby-systemu" ,ruby-systemu)))
    (native-inputs
     `(("bundler" ,bundler)
       ("ruby-rspec" ,ruby-rspec)))
    (synopsis "Simplified running of shell commands from within Ruby")
    (description
     "Bio-commandeer is a dead simple opinionated method of running shell
commands from within Ruby.  The advantage of bio-commandeer over other methods
of running external commands is that when something goes wrong, the error
message that is reported gives extra detail to ease debugging.")
    (home-page
     "http://github.com/wwood/bioruby-commandeer")
    (license license:expat)))

;;; Waiting to be pushed to guix alongside the OrfM update.
(define-public ruby-systemu
  (package
    (name "ruby-systemu")
    (version "2.6.5")
    (source
     (origin
       (method url-fetch)
       (uri (rubygems-uri "systemu" version))
       (sha256
        (base32
         "0gmkbakhfci5wnmbfx5i54f25j9zsvbw858yg3jjhfs5n4ad1xq1"))))
    (build-system ruby-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'check 'patch-version
           (lambda _
             (substitute* "Rakefile"
               (("  This.lib = lib")
                "  This.lib = 'systemu'")
               ((" version = ENV\\['VERSION'\\]")
                (string-append "version='" ,version "'"))))))))
    (synopsis "Capture of stdout/stderr and handling of child processes")
    (description
     "Systemu can be used on any platform to return status, stdout, and stderr
of any command.  Unlike other methods like open3/popen4 there is no danger of
full pipes or threading issues hanging your process or subprocess.")
    (home-page "https://github.com/ahoward/systemu")
    (license license:ruby)))