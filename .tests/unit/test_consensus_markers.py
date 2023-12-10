import bz2
import os
import pickle
import pytest
import sys
from pathlib import Path
from unittest.mock import patch

sys.path.append(Path(__file__).parents[2].joinpath("scripts").as_posix())
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "scripts"))
print(Path(__file__).parents[2].joinpath("scripts").as_posix())
from consensus_markers_f import is_bz2_empty, run_sample2markers


@pytest.fixture
def empty_bz2_file(tmpdir):
    fp = tmpdir.join("empty.bz2")
    with bz2.open(fp, "wt") as f:
        f.write("")

    yield Path(fp)


@pytest.fixture
def non_empty_bz2_file(tmpdir):
    fp = tmpdir.join("nonempty.bz2")
    with bz2.open(fp, "wt") as f:
        f.write("CONTENT")

    yield Path(fp)


@pytest.fixture
def output_fp(tmpdir):
    # Create a temporary output file
    output_file = tmpdir.join("output.txt")
    return Path(output_file)


@pytest.fixture
def pickle_fp(tmpdir):
    # Create a temporary pickle file
    pickle_file = tmpdir.join("data.pickle")
    return Path(pickle_file)


@pytest.fixture
def output_dir(tmpdir):
    # Create a temporary output directory
    return Path(tmpdir)


@pytest.fixture
def threads():
    return 4


def test_is_bz2_empty_with_empty_file(empty_bz2_file):
    assert is_bz2_empty(empty_bz2_file) is True


def test_is_bz2_empty_with_non_empty_file(non_empty_bz2_file):
    assert is_bz2_empty(non_empty_bz2_file) is False


def test_run_sample2markers_with_empty_input(
    empty_bz2_file, output_fp, pickle_fp, output_dir, threads
):
    with patch("consensus_markers_f.is_bz2_empty", return_value=True):
        run_sample2markers(empty_bz2_file, output_fp, pickle_fp, output_dir, threads)

    assert pickle.load(open(output_fp, "rb")) == []
