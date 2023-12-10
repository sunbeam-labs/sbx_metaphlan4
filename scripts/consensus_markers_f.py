import bz2
import pickle
import subprocess as sp


def is_bz2_empty(fp):
    """
    Check if a bz2 file is empty.

    Args:
        fp (str): The file path of the bz2 file.

    Returns:
        bool: True if the file is empty, False otherwise.
    """
    with bz2.open(fp, "r") as f_in:
        if f_in.read():
            return False
        else:
            return True


def run_sample2markers(input_fp, output_fp, pickle_fp, output_dir, threads):
    """
    Run the sample2markers.py script with the given input and output parameters.

    Args:
        input_fp (str): File path of the input file.
        output_fp (str): File path of the output file.
        pickle_fp (str): File path of the pickle file.
        output_dir (str): Directory path for the output files.
        threads (int): Number of threads to use.

    Returns:
        None
    """
    if not is_bz2_empty(input_fp):
        args = [
            "sample2markers.py",
            "-i",
            input_fp,
            "-d",
            pickle_fp,
            "-o",
            output_dir,
            "-n",
            str(threads),
        ]
        sp.run(args, check=True)
    else:
        with open(output_fp, "wb") as f_out:
            pickle.dump([], f_out)
