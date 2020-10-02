#!/bin/bash
start=`date +%s`

printf "\nUse SPDBV to repair missing atoms.\n"
gmx pdb2gmx -f 1d01_singlechain.pdb -o 1.gro -p 1.top -water spce -ff oplsaa

# printf "\nUse this command while working to ignore the hydrogen atoms if consisted, because it generates few complications while compiling in later phases: \n"
# gmx pdb2gmx -f 1d01_singlechain.pdb -o 1.gro -p 1.top -water spce -ignh

printf "\nEmbed the protein in a Cubic Box for simulation:\n"
gmx editconf -f 1.gro -o box.gro -c -d 1.0 -bt cubic

printf "\nAdd the solvent system:\n"
gmx solvate -cp box.gro -cs spc216.gro -o water_box.gro -p 1.top

printf "\nNow we need to neutralize our molecule , go to the main topology file (1.top) , find qtot and see if its +ve or -ve , we need to add the exactly opposite charge quantity to neutralize it.\n"
gmx grompp -f ions.mdp -c water_box.gro -p 1.top -o ions.tpr

printf "\nNow we assemble the tpr file and time to neutralize our system.\n"
gmx genion -s ions.tpr -o water_ions.gro -p 1.top -pname NA -nname CL -neutral
<<13

printf "\nSelect the solvent system (SOL) after you run the above command.\n"


printf "\nNow we do Energy Minimization :\n"
gmx grompp -f minim.mdp -c water_ions.gro -p 1.top -o energyminimization.tpr

printf "\nNow we have created the system, now it's time to run the  MD(Molecular Dynamics) command:\n"
gmx mdrun -v -s energyminimization.tpr -deffnm em  

printf "\nNow, energy has been minimized. We can see the graph by running:\n"
gmx energy -f em.edr -o potential.xvg

printf "\nWe now stabilize our system:\n"
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p 1.top -o nvt.tpr

gmx mdrun -deffnm nvt

printf "\nNow, the temperature is completely stable, now its time to stabilize the Pressure\n"
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p 1.top -o npt.tpr

gmx mdrun -deffnm npt

printf "\nNow run the simulation command:\n"
gmx grompp -f md.mdp -c npt.gro -t npt .cpt -p 1.top -o full_md.tpr

gmx mdrun -deffnm full_md

printf "\nNow we can make the RMSD graph:\n"
gmx rms -s full_md.tpr -f full_md1.xtc -o rmsd.xvg

printf "\nSimilarly for RMSF and gyrate:\n"
gmx rmsf -s full_md.tpr -f full_md1.xtc -res -o rmsf.xvg

gmx gyrate -s full_md.tpr -f full_md1.xtc -o gyr.xvg

printf "\nWe can change these .xvg files to .csv and visualize the graph\n"

end=`date +%s`
runtime=$((end-start))
printf "\n"
echo "Script ran in $runtime seconds"
