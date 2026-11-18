# Run each CP2K input on 2 MPI ranks x 2 OpenMP threads and compare the
# energy, largest atomic force, and pressure with reference.txt.
set -eu
dir=$1
export HOME=$TMPDIR OMP_NUM_THREADS=2
for inp in "$dir"/*.inp; do
  name=$(basename "$inp" .inp)
  mpirun -np 2 -x OMP_NUM_THREADS cp2k.psmp -i "$inp" -o "$name.out"
done
awk '
  FNR == 1 { file = FILENAME; sub(/\.out$/, "", file) }
  /ENERGY\| Total FORCE_EVAL/ { got[file, "energy"] = $NF }
  /^ FORCES\| +[0-9]+ / { if ($NF + 0 > got[file, "fmax"] + 0) got[file, "fmax"] = $NF }
  /STRESS\| 1\/3 Trace/ { got[file, "pressure"] = $NF }
  END {
    while ((getline line < ref) > 0) {
      if (line ~ /^#/) continue
      split(line, f)
      key = f[1] SUBSEP f[2]
      if (!(key in got)) { print "missing:", f[1], f[2]; bad = 1; continue }
      d = got[key] - f[3]; if (d < 0) d = -d
      status = d <= f[4] ? "ok  " : "FAIL"
      if (d > f[4]) bad = 1
      printf "%s %-11s %-8s got %s ref %s diff %.3g\n", status, f[1], f[2], got[key], f[3], d
    }
    exit bad
  }' ref="$dir/reference.txt" *.out
