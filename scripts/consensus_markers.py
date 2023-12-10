from consensus_markers import run_sample2markers

run_sample2markers(snakemake.input[0], snakemake.output[0], snakemake.params.pickle, snakemake.params.outdir, snakemake.threads)