package main

import (
	"bufio"
	"fmt"
	"io"
	"math"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

type atom struct {
	elem string
	x    float64
	y    float64
	z    float64
}

type molecule struct {
	len       int64
	atoms     []atom
	energy    float64
	confClass int
}

func parseAtom(line string) (out atom) {
	fields := strings.Fields(line)
	print(fields)
	out.elem = fields[0]

	out.x, _ = strconv.ParseFloat(fields[1], 64)
	out.y, _ = strconv.ParseFloat(fields[2], 64)
	out.z, _ = strconv.ParseFloat(fields[3], 64)

	return
}

func confMatch(molA *molecule, molB *molecule) bool {
	if molA.len != molB.len {
		return false
	}

	for i := range molA.len {
		if molA.atoms[i].elem == "H" {
			continue
		}
		if (math.Abs(molA.atoms[i].x-molB.atoms[i].x) < 0.1) && (math.Abs(molA.atoms[i].y-molB.atoms[i].y) < 0.1) && (math.Abs(molA.atoms[i].z-molB.atoms[i].z) < 0.1) {
			continue
		}
		fmt.Printf("No Match: %f, %f, %f - %f, %f, %f\n", molA.atoms[i].x, molA.atoms[i].y, molA.atoms[i].z, molB.atoms[i].x, molB.atoms[i].y, molB.atoms[i].z)
		fmt.Printf("Diff x: %f, Diff y: %f, Diff z: %f\n\n", math.Abs(molA.atoms[i].x-molB.atoms[i].x), math.Abs(molA.atoms[i].y-molB.atoms[i].y), math.Abs(molA.atoms[i].z-molB.atoms[i].z))
		return false
	}

	return true
}

func printMolecule(w io.Writer, mol *molecule, idx int) {
	fmt.Fprintf(w, "%d\n", mol.len)
	fmt.Fprintf(w, "conf%d\tEnergy: %f\n", idx, mol.energy)
	for _, a := range mol.atoms {
		fmt.Fprintf(w, "%s\t%f\t%f\t%f\n", a.elem, a.x, a.y, a.z)
	}
}

func main() {
	args := os.Args[1:]
	if len(args) != 1 {
		panic("Incorrect number of arguments: expect 1\nUsage: go run conf_filt.go <conformers.xyz>")
	}

	file, err := os.Open(args[0])
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	molIndex := -1
	molecules := make([]molecule, 0)

	energy_sum := 0.0

	for scanner.Scan() {
		line := scanner.Text()
		println(line)
		matched, _ := regexp.MatchString("^\\d+", line)
		if matched {
			length, err := strconv.ParseInt(line, 10, 64)
			if err != nil {
				panic("Malformed xyz file: failed to parse molecule length")
			}
			molIndex++
			molecules = append(molecules, molecule{len: length})
			continue
		}

		matched, _ = regexp.MatchString("Energy:", line)
		if matched {
			energy, err := strconv.ParseFloat(strings.TrimSpace(strings.Split(line, ":")[1]), 64)
			if err != nil {
				panic(err)
			}

			energy_sum += energy
			molecules[molIndex].energy = energy
			continue
		}

		molecules[molIndex].atoms = append(molecules[molIndex].atoms, parseAtom(line))
	}

	// avg_energy := energy_sum / float64(len(molecules))

	// for _, m := range molecules {
	// 	println(m.len)
	// 	println(m.energy)
	// 	for i, a := range m.atoms {
	// 		fmt.Printf("%d: %s, %f, %f, %f\n", i, a.elem, a.x, a.y, a.z)
	// 	}
	// }

	// filteredMolecules := make([]molecule, 0, molIndex)

	// for _, m := range molecules {
	// 	if m.energy < avg_energy {
	// 		filteredMolecules = append(filteredMolecules, m)
	// 	}
	// }

	sort.Slice(molecules, func(i, j int) bool {
		return molecules[i].energy < molecules[j].energy
	})

	length := len(molecules)
	confClassIdx := 1

	for i := range length {
		if molecules[i].confClass != 0 {
			continue
		}
		molecules[i].confClass = confClassIdx

		for j := range length - i - 1 {
			if confMatch(&molecules[i], &molecules[j+i+1]) {
				fmt.Printf("Conf Match %d - %d: Conf class %d", i, j+i+1, confClassIdx)
				molecules[j+i+1].confClass = confClassIdx
			}
		}
		confClassIdx++
	}

	f, err := os.Create("filtConfs.xyz")

	if err != nil {
		panic("Failed to create output file")
	}

	nextConfClass := 1
	maxEnergy := molecules[0].energy + 5

	for i, mol := range molecules {
		if mol.confClass < nextConfClass || mol.energy > maxEnergy {
			continue
		}
		fmt.Printf("Molecule %d: %d\n", i, mol.confClass)
		printMolecule(f, &mol, i)
		nextConfClass++
	}
}
