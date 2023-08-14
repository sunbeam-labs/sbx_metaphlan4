# -*- mode: Snakemake -*-
#
# Rules for running Metaphlan4

TARGET_METAPHLAN = expand(str(CLASSIFY_FP/'metaphlan4'/'review'/'{sample}_profile.txt'), sample = Samples.keys())
TARGET_METAPHLAN_REPORT = [str(CLASSIFY_FP/'metaphlan4'/'taxonomic_assignments.tsv')]

try:
    BENCHMARK_FP
except NameError:
    BENCHMARK_FP = output_subdir(Cfg, "benchmarks")
try:
    LOG_FP
except NameError:
    LOG_FP = output_subdir(Cfg, "logs")


localrules:
    all_metaphlan4,


rule all_metaphlan4:
    input:
        TARGET_METAPHLAN_REPORT

rule metaphlan_bowtie:
    log:
        LOG_FP / "metaphlan_bowtie_{sample}.log",
    benchmark:
        BENCHMARK_FP / "metaphlan_bowtie_{sample}.tsv",
    output: str(CLASSIFY_FP/'metaphlan'/'raw'/'{sample}.bowtie2.sam.bz2')
    input:
        pair = expand(str(QC_FP/'decontam'/'{sample}_{rp}.fastq.gz'),
                      sample = "{sample}",
                      rp = Pairs),
        dbdir = Cfg['sbx_metaphlan4']['dbdir'],
        dbname = Cfg['sbx_metaphlan4']['dbname']
    threads:
        Cfg['sbx_metaphlan4']['threads']
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            metaphlan {input.pair[0]},{input.pair[1]} \
            --bowtie2out {output} \
            --nproc {threads} \
            --input_type fastq \
            --bowtie2db {input.dbdir} \
            --index {input.dbname}
        """
