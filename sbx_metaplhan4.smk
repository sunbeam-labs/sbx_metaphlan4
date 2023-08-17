# -*- mode: Snakemake -*-
#
# Rules for running Metaphlan4

TARGET_METAPHLAN4_REPORT = [CLASSIFY_FP/'metaphlan4'/'metaphlan4_assignments.tsv']
TARGET_METAPHLAN4_STRAIN = CLASSIFY_FP/'metaphlan4'/'output_tree'/f'{Cfg["sbx_metaphlan4"]["profile_strain"]}.info'

try:
    BENCHMARK_FP
except NameError:
    BENCHMARK_FP = output_subdir(Cfg, "benchmarks")
try:
    LOG_FP
except NameError:
    LOG_FP = output_subdir(Cfg, "logs")

rule all_metaphlan4:
    input:
        TARGET_METAPHLAN4_REPORT,TARGET_METAPHLAN4_STRAIN if Cfg['sbx_metaphlan4']['profile_strain'] else TARGET_METAPHLAN4_REPORT

# rule all_metaphlan4:
#     input:
#         TARGET_METAPHLAN4_REPORT

rule taxonomic_assignment_report:
    """ generate metaphlan taxonomic assignment table """
    log:
        LOG_FP / "metaphlan4_report.log",
    benchmark:
        BENCHMARK_FP / "metaphlan4_report.tsv",
    output:
        CLASSIFY_FP/'metaphlan4'/'metaphlan4_assignments.tsv'
    input:
        expand(CLASSIFY_FP/'metaphlan4'/'profiles'/'{sample}.profiled.txt', sample = Samples.keys())
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            merge_metaphlan_tables.py \
            -o {output} \
            {input} 2>&1 | tee {log}
        """

rule metaphlan4_bowtie:
    """ make individual metaphlan profiles with intermediate bowtie outputs """
    log:
        LOG_FP / "metaphlan4_bowtie_{sample}.log",
    benchmark:
        BENCHMARK_FP / "metaphlan4_bowtie_{sample}.tsv",
    output: 
        bt2 = CLASSIFY_FP/'metaphlan4'/'bowtie2out'/'{sample}.bowtie2.bz2',
        profile = CLASSIFY_FP/'metaphlan4'/'profiles'/'{sample}.profiled.txt',
        sam = CLASSIFY_FP/'metaphlan4'/'sams'/'{sample}.sam.bz2'
    input:
        pair = expand(QC_FP / "decontam" / "{{sample}}_{rp}.fastq.gz", rp=Pairs),
    params:
        dbdir = Cfg['sbx_metaphlan4']['dbdir'],
        dbname = Cfg['sbx_metaphlan4']['dbname']
    threads:
        Cfg['sbx_metaphlan4']['threads']
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            metaphlan {input.pair[0]},{input.pair[1]} \
            -t rel_ab_w_read_stats \
            --bowtie2out {output.bt2} \
            --samout {output.sam} \
            --nproc {threads} \
            --input_type fastq \
            --bowtie2db {params.dbdir} \
            --index {params.dbname} \
            -o {output.profile} \
            2>&1 | tee {log}
        """

rule extract_markers:
    """ extract markers for a given strain """
    log:
        LOG_FP / "extract_markers.log",
    benchmark:
        BENCHMARK_FP / "extract_markers.tsv",
    output: 
        markers = CLASSIFY_FP/'metaphlan4'/'db_markers'/f'{Cfg["sbx_metaphlan4"]["profile_strain"]}.fna'
    input:
        Cfg['sbx_metaphlan4']['profile_strain'] #this might not work because its not used in the shell command
    params:
        dbdir = Cfg['sbx_metaphlan4']['dbdir'],
        dbname = Cfg['sbx_metaphlan4']['dbname']
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            extract_markers.py \
            -d dbdir = {params.dbdir}/{params.dbname}.pkl \
            -c {input} \
            -o db_markers/ \
            2>&1 | tee {log} && \
            find db_markers/*temp* -delete
        """

rule consensus_markers:
    """ extract consensus markers from the samples """
    log:
        LOG_FP / "{sample}_consensus_markers.log",
    benchmark:
        BENCHMARK_FP / "{sample}_consensus_markers.tsv",
    output: 
        CLASSIFY_FP/'metaphlan4'/'consensus_markers'/'{sample}.pkl'
    input:
        CLASSIFY_FP/'metaphlan4'/'sams'/'{sample}.sam.bz2'
    threads:
        Cfg['sbx_metaphlan4']['threads']
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            sample2markers.py \
            -i {input} \
            -o {output} -n {threads} \
            2>&1 | tee {log}
        """

rule build_tree:
    """ Build the multiple sequence alignment and the phylogenetic tree """
    log:
        LOG_FP / "build_tree.log",
    benchmark:
        BENCHMARK_FP / "build_tree.tsv",
    output: 
        CLASSIFY_FP/'metaphlan4'/'output_tree'/f'{Cfg["sbx_metaphlan4"]["profile_strain"]}.info'
    input:
        consensus_markers = expand(CLASSIFY_FP/'metaphlan4'/'consensus_markers'/'{sample}.pkl', sample = Samples.keys()),
        db_markers = CLASSIFY_FP/'metaphlan4'/'db_markers'/f'{Cfg["sbx_metaphlan4"]["profile_strain"]}.fna'
    params:
        strain = Cfg['sbx_metaphlan4']['profile_strain'],
        ref_genome = Cfg['sbx_metaphlan4']['reference_genome'] #might need to bzip2 this
    threads:
        Cfg['sbx_metaphlan4']['threads']
    conda:
        "sbx_metaphlan4_env.yml"
    shell:
        """
            strainphlan \
            -s {input.consensus_markers} \
            -m {input.db_markers} \
            -r {params.ref_genome} \
            -o output_tree -n {threads} \
            -c {params.strain} --mutation_rates \
            2>&1 | tee {log}
        """