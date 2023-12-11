import bz2
import pickle
import subprocess as sp

with bz2.open(snakemake.input[0], "r") as f_in:
    if f_in.read():
        empty = False

if empty:
    args = ["sample2markers.py", "-i", snakemake.input[0], "-d", snakemake.params.pickle, "-o", snakemake.params.outdir, "-n", str(snakemake.threads)]
    sp.run(args, check=True)
else:
    with open(snakemake.output[0], "wb") as f_out:
        pickle.dump([], f_out)