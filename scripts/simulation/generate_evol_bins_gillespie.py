#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov 28 11:49:09 2020

@author: mariatrofimova
"""
from random import choice
import numpy as np
import csv
import os
import datetime
import random
import math
import copy

from pathlib import Path

strptime = datetime.datetime.strptime


class generateEvolGill:

    def __init__(self, length, p_repl, p_repl2, p_death, p_mut, N, t_start, t_final, t_switch, out, sim, total_sim, init_seq):
        self.length = length
        self.p_repl = p_repl
        self.p_repl2 = p_repl2
        self.p_death = p_death
        self.p_mut = p_mut
        self.N = N
        self.init = self._initSetID(init_seq)
        self.initNoID = self._initSet(init_seq)
        self.t_start = t_start
        self.t_final = t_final
        self.t_switch = t_switch
        self.outdir = out
        self.sim = sim
        self.total_sim = total_sim
    
    def _initSetID(self,init_seq):
        '''
        Create initial sequence, if parameter is None, or use predefined initial sequence
        '''
        if init_seq=='none':
            alphabet = 'ACGT'
            sequences = []
            seq = ''.join(choice(alphabet) for i in range(self.length))
            sequences = [seq] * self.N
            #labels = np.arange(0,len(sequences))
            init = []
            for i in range(len(sequences)):
                init.append((i,sequences[i]))
            return init
        else:
            sequences = [init_seq] * self.N
            #labels = np.arange(0,len(sequences))
            init = []
            for i in range(len(sequences)):
                init.append((i,sequences[i]))
            return init
        
    def _initSet(self,init_seq):
        '''
        Create initial sequence, if parameter is None, or use predefined initial sequence
        '''
        if init_seq=='none':
            alphabet = 'ACGT'
            sequences = []
            seq = ''.join(choice(alphabet) for i in range(self.length))
            sequences = [seq] * self.N
            #labels = np.arange(0,len(sequences))
            init = []
            for i in range(len(sequences)):
                init.append(sequences[i])
            return init
        else:
            sequences = [init_seq] * self.N
            #labels = np.arange(0,len(sequences))
            init = []
            for i in range(len(sequences)):
                init.append(sequences[i])
            return init
        
    def _initSetB(self):
        z = np.zeros(self.length)
        zset = []
        for i in range(self.N):
            zset.append((i,z))
        return zset

    def _mutateBase(self,base,initSeqBase):
        '''
        Mutate individual sequences according
        to Kimura model, fixed transition probability
        '''
        # Mutate if the base didnt mutate yet
        if base==initSeqBase:
            stay = 0
            alpha = 0.2
            beta = 0.2
            gamma = 0.6

            transitions = {'A':'T','T':'A','C':'G','G':'C'}
            transversions_alpha = {'A':'C','C':'A','T':'G','G':'T'}
            transversions_beta = {'A':'G','G':'A','T':'C','C':'T'}

            r = np.random.uniform(0,1)

            if stay <= r < (stay+gamma):
                return transitions[base]
            elif (stay+gamma) <= r < (stay+gamma+alpha):
                return transversions_alpha[base]
            elif (stay+gamma+alpha) <= r < (stay+gamma+alpha+beta):
                return transversions_beta[base]
            return base
        else:
            return base

    def _mutateBasenorm(self,base):
        '''
        Mutate individual sequences according
        to Kimura model, fixed transition probability
        '''
        stay = 0
        alpha = 0.2
        beta = 0.2
        gamma = 0.6

        transitions = {'A':'T','T':'A','C':'G','G':'C'}
        transversions_alpha = {'A':'C','C':'A','T':'G','G':'T'}
        transversions_beta = {'A':'G','G':'A','T':'C','C':'T'}

        r = np.random.uniform(0,1)

        if stay <= r < (stay+gamma):
            return transitions[base]
        elif (stay+gamma) <= r < (stay+gamma+alpha):
            return transversions_alpha[base]
        elif (stay+gamma+alpha) <= r < (stay+gamma+alpha+beta):
            return transversions_beta[base]
        return base

    def _writeFile(self, t, foldername, init, curr_time):
        '''
        Write the alignment at time t to file
        '''
        FILEPATH = Path(self.outdir)
        tname = str(t)
        tot_t_order = len(str(self.t_final))
        diff_t_tfinal = len(str(t))
        n_zero = tot_t_order-diff_t_tfinal
        zeros = "0" * n_zero
        tname = zeros+str(t)
        name = 't'+tname+'.fasta'

        file1 = FILEPATH / foldername
        file2 = file1 / 'bins'
        file = file2 / 'per_gen'
        file_name = file / name
        outfile = str(file_name)
        os.makedirs(file, exist_ok=True)

        with open(outfile, 'w') as csvfile:
            writer = csv.writer(csvfile, delimiter='\t')
            for i in range(len(init)):
                writer.writerow([">alignment_"+str(i)+'_'+str(curr_time.strftime("%Y-%m-%d"))])
                writer.writerow([init[i]])
                
    def initReplRates(self,initlen):
        return np.full(initlen,self.p_repl)

    def mutateID(self):
        '''
        Mutate initial sequence set over the course of t generations
        '''
        init = self.init
        print(init)
        initSeq = init[0]
        prefRep = False
        repl_rates = self.initReplRates(len(init))
        # If some mutants have better fitness
        if prefRep == True:
            pick_pref = random.choices(np.arange(0,len(init)), weights=np.full(len(init), 1/len(init)),k=3)
            for i in pick_pref:
                repl_rates[i] = repl_rates[i] + 0.03
        print("Replication rates: ",repl_rates)
        t = self.t_start
        time_steps = []
        time_steps.append(init)
        L = self.length
        # Propensities of sites to mutate
        mut_prop_per_seq = list(np.full(L,1/(L+3)))
        # Some sites should be more likely
#        incr_weight = (1-sum(mut_prop_per_seq))/3
#        mut_prop_per_seq[math.floor(0.3*L)] = mut_prop_per_seq[math.floor(0.3*L)]+incr_weight
#        mut_prop_per_seq[math.floor(0.6*L)] = mut_prop_per_seq[math.floor(0.6*L)]+incr_weight
#        mut_prop_per_seq[math.floor(0.9*L)] = mut_prop_per_seq[math.floor(0.9*L)]+incr_weight     

        # Create folder for the simulation
#        sim_name = self.sim
#        tot_sim_order = len(str(self.total_sim))
#        diff_sim_atot = len(str(self.sim))
#        n_zero = tot_sim_order-diff_sim_atot
#        zeros = "0" * n_zero

        trajectory = []
        time_trajectory = []
        tipsList = []

        curr_p_repl = self.p_repl
        benchmark = 0
        step = 1
        
        # Keep track of recurrent mutants
        rec_mutants = dict()

        while t<self.t_final:
            if t>=benchmark:
                print("Cureent time t: ",t)
                #print("Replication rates: ", repl_rates)
                benchmark = benchmark+step
                print("Recording trajectory snapshot...")
                trajectory.append(init)
            #print("Current time T = ",t)
            # Switch the replication rate somewhere in the middle if that is the correct mode (p_repl2!=0)
            if (self.p_repl2!=0) and (t>=self.t_switch) and (curr_p_repl!=self.p_repl2):
                print("Switching replication rate")
                curr_p_repl = self.p_repl2
                #new_repl_rates = np.full(len(repl_rates),curr_p_repl)
                repl_rates = repl_rates-0.2
            
            #print("Size of init: ",len(init))
            #print("Size of replication rates: ",len(repl_rates))
                
            r_repl = sum(repl_rates)
            #print("Replication rate: ",r_repl)
            r_death = self.p_death*len(init)
            #print("Death rate: ",r_death)
            rate = (r_repl,r_death)
            
            u1 = random.uniform(0,1)
            u2 = random.uniform(0,1)
            while isinstance(u1, complex):
                u1 = random.uniform(0,1)
            delta_t = (1/sum(rate))*math.log(1/u1)
            while isinstance(u2, complex):
                u2 = random.uniform(0,1)
            
            
            csum_rate = (r_repl/(r_repl+r_death),r_death/(r_repl+r_death))
            csum = np.cumsum(csum_rate)
            r = u2*sum(csum_rate) 
            
            repl_event = False
            death_event = False
            
            if r < csum[0]:
                repl_event = True
            elif csum[0] < r < csum[1]:
                death_event = True
            

            new_set = []
            
            # Add sequences to list if birth event
            if repl_event == True:
                #print("  Picked replication event")
                # Pick sequences to replicate with a certain probability - by index
                #pick_ind = random.choices(np.arange(0,len(init)), weights=np.full(len(init), curr_p_repl/r_repl),k=math.ceil(len(init)*(curr_p_repl/r_repl)))
                pick_ind = random.choices( np.arange(0,len(init)), weights=repl_rates, k=1)
                #print("Sequences to replicate: ",pick_ind)
                # Initialize mutated sites
                num_mut_sites = len(pick_ind)*L*2 + 1
                while num_mut_sites >= len(pick_ind)*L*2:
                    num_mut_sites = np.random.poisson(self.p_mut*len(pick_ind)*L*2)
                #print("                Number of mutated sites: ",num_mut_sites)
                ind_mut_sites = np.arange(0,len(pick_ind)*L*2)
                mut_sites = random.choices(ind_mut_sites.tolist(),weights=mut_prop_per_seq*2,k=num_mut_sites)
                #print("Mutating sites: ",mut_sites)
                
                pick_children = []
                
                for ind in pick_ind:
                    pick_children.append(init[ind])
                    pick_children.append(init[ind])
                    repl_rates = np.append(repl_rates,repl_rates[ind])
                    repl_rates = np.append(repl_rates,repl_rates[ind])
                #List sequence identities in init
                identities = []
                for seq in init:
                    identities.append(seq[0])
                maxIdent = max(identities)
                if num_mut_sites > 0:
                    for i in mut_sites:
                        seq_ind = math.floor(i/L)
                        seq_pos = i % L
                        seq = list(pick_children[seq_ind][1])
                        
                        if (seq_pos in rec_mutants.keys()) and (seq[seq_pos]==initSeq[1][seq_pos]):
                            # If it is a recurrent mutant, assign a new sequence identity
                            rec_mutants[seq_pos].append(t)
                            pick_children[seq_ind] = (maxIdent+1,pick_children[seq_ind][1])
                            maxIdent = maxIdent+1
                        else:
                            rec_mutants[seq_pos] = [t]
        
                        #print(seq)
                        #seq[seq_pos] = self._mutateBase(new_set[seq_ind][seq_pos],initSeq[seq_pos])
                        seq[seq_pos] = self._mutateBasenorm(seq[seq_pos],initSeq[1][seq_pos])
                        
                        #print("                       Mutated site: ",seq_pos)
                        s = "".join(seq)
                        pick_children[seq_ind] = (pick_children[seq_ind][0],s)
                # If birth event - no tips available
                tipsList.append([])
                # Append children to init
                for seq in pick_children:
                    init.append(seq)
                #print("   New init size: ",len(init))
            # if death event - remove sequences from population        
            elif death_event == True:
                #print("Picked death event")
                pick = []
                pick_ind = random.choices(np.arange(0,len(init)), weights=np.full(len(init), self.p_death/r_death), k=math.ceil(len(init)*(self.p_death/r_death)))
                
                new_init = []
                new_repl = []
                for idx in range(len(init)):
                    if idx in pick_ind:
                        pick.append(init[idx])
                    else:
                        new_init.append(init[idx])
                        new_repl.append(repl_rates[idx])
                init = copy.deepcopy(new_init)
                repl_rates = copy.deepcopy(np.array(new_repl))
                #print("   New init size: ",len(init))
                tipsList.append(pick)
                
            # Add to trajectory
            new_set = copy.deepcopy(init)
            #trajectory.append(new_set)
            t = t + delta_t
            time_trajectory.append(t)
            
            if len(new_set)==0:
                break
        print(rec_mutants)
        return trajectory, time_trajectory, initSeq, tipsList, rec_mutants
    
    def mutate(self):
        '''
        Mutate initial sequence set over the course of t generations
        '''
        init = self.initNoID
        print(init)
        prefRep = True
        repl_rates = self.initReplRates(len(init))
        # If some mutants have better fitness
        if prefRep == True:
            pick_pref = random.choices(np.arange(0,len(init)), weights=np.full(len(init), 1/len(init)),k=3)
            for i in pick_pref:
                repl_rates[i] = repl_rates[i] + 0.1
        print("Replication rates: ",repl_rates)
        initSeq = init[0]
        t = self.t_start
        time_steps = []
        time_steps.append(init)
        L = self.length
        # Propensities of sites to mutate
        mut_prop_per_seq = list(np.full(L,1/(L+3)))
        # Some sites should be more likely
        #incr_weight = (1-sum(mut_prop_per_seq))/3
        #mut_prop_per_seq[math.floor(0.3*L)] = mut_prop_per_seq[math.floor(0.3*L)]+incr_weight
        #mut_prop_per_seq[math.floor(0.6*L)] = mut_prop_per_seq[math.floor(0.6*L)]+incr_weight
        #mut_prop_per_seq[math.floor(0.9*L)] = mut_prop_per_seq[math.floor(0.9*L)]+incr_weight        

        # Create folder for the simulation
#        sim_name = self.sim
#        tot_sim_order = len(str(self.total_sim))
#        diff_sim_atot = len(str(self.sim))
#        n_zero = tot_sim_order-diff_sim_atot
#        zeros = "0" * n_zero
        mutated_positions = []

        trajectory = []
        time_trajectory = []
        tipsList = []

        curr_p_repl = self.p_repl
        benchmark = 0
        step = 1
        
        # Keep track of recurrent mutants
        rec_mutants = dict()

        while t<self.t_final:
            if t>=benchmark:
                print("Cureent time t: ",t)
                #print("Replication rates: ", repl_rates)
                benchmark = benchmark+step
                print("Recording trajectory snapshot...")
                trajectory.append(init)
            #print("Current time T = ",t)
            # Switch the replication rate somewhere in the middle if that is the correct mode (p_repl2!=0)
            if (self.p_repl2!=0) and (t>=self.t_switch) and (curr_p_repl!=self.p_repl2):
                print("Switching replication rate")
                curr_p_repl = self.p_repl2
                #new_repl_rates = np.full(len(repl_rates),curr_p_repl)
                repl_rates = repl_rates-0.1
#            if (self.p_repl!=0) and (t>=self.t_switch*1.5) and (curr_p_repl!=self.p_repl):
#                print("Switching replication rate back")
#                curr_p_repl = self.p_repl
#                #new_repl_rates = np.full(len(repl_rates),curr_p_repl)
#                repl_rates = repl_rates+0.2
            #print("Size of init: ",len(init))
            #print("Size of replication rates: ",len(repl_rates))
                
            r_repl = sum(repl_rates)
            #print("Replication rate: ",r_repl)
            r_death = self.p_death*len(init)
            #print("Death rate: ",r_death)
            rate = (r_repl,r_death)
            
            u1 = random.uniform(0,1)
            u2 = random.uniform(0,1)
            while isinstance(u1, complex):
                u1 = random.uniform(0,1)
            delta_t = (1/sum(rate))*math.log(1/u1)
            while isinstance(u2, complex):
                u2 = random.uniform(0,1)
            
            
            csum_rate = (r_repl/(r_repl+r_death),r_death/(r_repl+r_death))
            #print("csum_rate ",csum_rate)
            csum = np.cumsum(csum_rate)
            r = u2*sum(csum_rate) 
            
            repl_event = False
            death_event = False
            
            if r < csum[0]:
                repl_event = True
            elif csum[0] < r < csum[1]:
                death_event = True
            

            new_set = []
            
            # Add sequences to list if birth event
            if repl_event == True:
                #print("  Picked replication event")
                # Pick sequences to replicate with a certain probability - by index
                #pick_ind = random.choices(np.arange(0,len(init)), weights=np.full(len(init), curr_p_repl/r_repl),k=math.ceil(len(init)*(curr_p_repl/r_repl)))
                pick_ind = random.choices( np.arange(0,len(init)), weights=repl_rates, k=1)
                #print("Sequences to replicate: ",pick_ind)
                # Initialize mutated sites
                num_mut_sites = len(pick_ind)*L*2 + 1
                while num_mut_sites >= len(pick_ind)*L*2:
                    num_mut_sites = np.random.poisson(self.p_mut*len(pick_ind)*L)
                #print("                Number of mutated sites: ",num_mut_sites)
                ind_mut_sites = np.arange(0,len(pick_ind)*L*2)
                mut_sites = random.choices(ind_mut_sites.tolist(),weights=mut_prop_per_seq*2,k=num_mut_sites)
                #print("Mutating sites: ",mut_sites)
                
                pick_children = []
                
                for ind in pick_ind:
                    pick_children.append(init[ind])
                    pick_children.append(init[ind])
                    repl_rates = np.append(repl_rates,repl_rates[ind])
                    repl_rates = np.append(repl_rates,repl_rates[ind])

                if num_mut_sites > 0:
                    for i in mut_sites:
                        if not i in mutated_positions:
                            mutated_positions.append(i)
                            seq_ind = math.floor(i/L)
                            seq_pos = i % L
                            seq = list(pick_children[seq_ind])
                           
                            if (seq_pos in rec_mutants.keys()) and (seq[seq_pos]==initSeq[seq_pos]):
                                #print("Recurrent mutant: ",seq_pos)
                                # If it is a recurrent mutant, assign a new sequence identity
                                rec_mutants[seq_pos].append(t)
                            else:
                                #print("New mutant: ",seq_pos)
                                rec_mutants[seq_pos] = [t]
                            #seq[seq_pos] = self._mutateBase(new_set[seq_ind][seq_pos],initSeq[seq_pos])
                            seq[seq_pos] = self._mutateBase(seq[seq_pos],initSeq[seq_pos])
                            
                            #print("                       Mutated site: ",seq_pos)
                            s = "".join(seq)
                            pick_children[seq_ind] = s
                # If birth event - no tips available
                tipsList.append([])
                # Append children to init
                for seq in pick_children:
                    init.append(seq)
                # Remove parent
                init.pop(pick_ind[0])
                repl_rates = np.delete(repl_rates,pick_ind[0])
                #print("   New init size: ",len(init))
            # if death event - remove sequences from population        
            elif death_event == True:
                #print("Picked death event")
                pick = []
                pick_ind = random.choices(np.arange(0,len(init)), weights=np.full(len(init), self.p_death/r_death), k=1)
                
                new_init = []
                new_repl = []
                for idx in range(len(init)):
                    if idx in pick_ind:
                        pick.append(init[idx])
                    else:
                        new_init.append(init[idx])
                        new_repl.append(repl_rates[idx])
                init = copy.deepcopy(new_init)
                repl_rates = copy.deepcopy(np.array(new_repl))
                #print("   New init size: ",len(init))
                tipsList.append(pick)
                
            # Add to trajectory
            new_set = copy.deepcopy(init)
            t = t + delta_t
            time_trajectory.append(t)
            
            if len(new_set)==0:
                break
        return trajectory, time_trajectory, initSeq, tipsList, rec_mutants
    
    
    def samplingProc(self,sampling_list,sampl_rate):
        sampled_sets = []
        for i,sample in enumerate(sampling_list):
            # Number of sequences to sample
            s_num = np.random.poisson(sampl_rate*len(sample))
            print("Number of seq to subsample: ",s_num)
            indices = np.arange(0,len(sample))
            s_indices = random.choices(indices, k=s_num)
            print("Indices to subsample: ",s_indices)
            u_indices = np.unique(np.array(s_indices))
            print("Unique indices to subsample: ",u_indices)
            print("Len sample: ",len(sample))
            sampled = []
            
            for ind in u_indices:
                sampled.append(sample[ind])
            sampled_sets.append(sampled)
        return sampled_sets
            
            
    def mutateCompressed(self):
        '''
        Mutate initial sequence set over the course of t generations
        '''
        init = self.initB
        initSeq = init[0][1]
        t = self.t_start
        time_steps = []
        time_steps.append(init)
        L = self.length

        trajectory = []
        time_trajectory = []
        tipsList = []

        curr_p_repl = self.p_repl

        while t<self.t_final:
            # Switch the replication rate somewhere in the middle if that is the correct mode (p_repl2!=0)
            if (self.p_repl2!=0) and (t>=self.t_switch):
                curr_p_repl = self.p_repl2
                
            #print("Current time: ",t)
            #print("Current set size ",len(init))
            r_repl = curr_p_repl*len(init)
            r_death = self.p_death*len(init)
            rate = (r_repl,r_death)
            
            u1 = random.uniform(0,1)
            u2 = random.uniform(0,1)
            while isinstance(u1, complex):
                u1 = random.uniform(0,1)
            delta_t = (1/sum(rate))*math.log(1/u1)
            while isinstance(u2, complex):
                u2 = random.uniform(0,1)
            r = u2*sum(rate) 
            
            csum = np.cumsum(rate)
            
            repl_event = False
            death_event = False
            
            if r < csum[0]:
                repl_event = True
            elif csum[0] < r < csum[1]:
                death_event = True
            
            # Add sequences to list if birth event
            if repl_event == True:
                print("  Picked replication event")
                # Pick sequences to replicate with a certain probability
                pick = []
                for ind, elem in enumerate(init):
                    up = random.uniform(0,1)
                    #print("        Probability to pick this seq: ", curr_p_repl/r_repl)
                    #print("        Random number: ", up)
                    if up <= (curr_p_repl/r_repl):
                        pick.append(elem)
                if pick == []:
                    pick = random.choices(init, weights=np.full(len(init), curr_p_repl/r_repl))
                
                #pick = random.choices(init, weights=np.full(len(init), curr_p_repl/r_repl))
                #print("  Size of replicating subpop: ", len(pick))
                # Initialize mutated sites
                num_mut_sites = len(pick)*L + 1
                while num_mut_sites >= len(pick)*L:
                    num_mut_sites = np.random.poisson(self.p_mut*len(pick)*L)
                #print("                Number of mutated sites: ",num_mut_sites)
                ind_mut_sites = np.arange(0,len(pick)*L)
                mut_sites = random.sample(ind_mut_sites.tolist(),num_mut_sites)
                
                pick_children = []
                for ind, elem in enumerate(pick):
                    pick_children.append(elem)
                    pick_children.append(elem)
                
                if num_mut_sites > 0:
                    for i in mut_sites:
                        
                        seq_ind = math.floor(i/L)
                        seq_pos = i % L
                        seq_label = pick_children[seq_ind][0]
                        seq = list(pick_children[seq_ind][1])
                        #seq[seq_pos] = self._mutateBase(new_set[seq_ind][seq_pos],initSeq[seq_pos])
                        seq[seq_pos] = 1 #self._mutateBasenorm(new_set[seq_ind][seq_pos])
                        #print("                       Mutated site: ",seq_pos)
                        #s = "".join(seq)
                        pick_children[seq_ind] = (seq_label,seq)
                
                labels = []
                for i in range(len(init)):
                    labels.append(init[i][0])
                max_label = max(labels)
                count = 1
                for seq in pick_children:
                    init.append((max_label+count,seq[1]))
                #print("   New init size: ",len(init))
                tipsList.append([])
                
            elif death_event == True:
                print("Picked death event")
                pick = []
                for ind, elem in enumerate(init):
                    up = random.uniform(0,1)
                    #print("        Probability to pick this seq: ", self.p_death/r_death)
                    #print("        Random number: ", up)
                    if up <= (self.p_death/r_death):
                        pick.append(elem)
                if pick == []:
                    pick = random.choices(init, weights=np.full(len(init), curr_p_repl/r_repl))
                
                #pick = random.choices(init, weights=np.full(len(init), self.p_death/r_death))
                #print("  Size of removed subpop: ", len(pick))
                #print(pick)
                new_init = []
                for i, elem in enumerate(init):
                    in_pick = False
                    for j, p in enumerate(pick):
                        if elem[0]==p[0]:
                            in_pick = True
                    if not in_pick:
                        new_init.append(elem)
                #new_init = [k for k in init if k not in pick]
                init = new_init
                #print("   New init size: ",len(init))
                tipsList.append(pick)
            
            # Add to trajectory
            new_set = copy.copy(init)
            trajectory.append(new_set)
            t = t + delta_t
            time_trajectory.append(t)

            #curr_time = curr_time+datetime.timedelta(days=self.time_delta)

            if new_set == []:
                break

        return trajectory, time_trajectory, initSeq, tipsList
            
            
            
