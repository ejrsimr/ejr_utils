#!/usr/bin/env python
# ejr: 2023-02-07
# lmd: 2023-02-07
# adapted from https://avrilomics.blogspot.com/2016/07/finding-all-descendants-of-go-term.html
# extract children for a list of GO terms
# is_a is hte classic definition of children, but we'd like flexibility for anything
from collections import defaultdict
import sys
import os
import re

names = {}

def main():

    # check the command-line arguments:
    if len(sys.argv) != 3 or os.path.exists(sys.argv[1]) == False:
        print("Usage: %s input_go_obo_file input_go_term" % sys.argv[0])
        sys.exit(1)
    input_obo_file = sys.argv[1] # the input gene ontology file eg. gene_ontology.WS238.obo
    input_term = sys.argv[2] # the input GO term of interest

    # read in the children of each GO term in the GO hierachy:
    go = initiate_go_dict(input_obo_file)

    print(go[input_term])
    # find all the descendants of the term 'input_go_term':
    descendants = find_all_descendants(input_term, go)

    # print results
    for descendant in descendants:
        print(descendant, ": ", go[descendant]['name'])

    
def initiate_go_dict(input_obo_file):
    go = {}

    with open(input_obo_file) as f:
        current_id = ''
        for line in f:
            line = line.rstrip()
            temp = line.split(": ") 
            if len(temp) > 1:
                field = temp[0]
                value = temp[1]
            # go term
                if field == "id":
                    current_id=value
                    go[current_id] = {}
                    go[current_id]["is_a"] = []
                    go[current_id]["part_of"] = []
                    go[current_id]["regulates"] = []
                    go[current_id]["negatively_regulates"] = []
                    go[current_id]["positively_regulates"] = []
                # description of go term
                elif field == "name":
                    go[current_id][field] = value 
                # is_a fields are just a Go term followed by description
                elif field == "is_a":
                    value =  re.sub(r'(GO:\d+) .+', "\\1", value)
                    go[current_id][field].append(value) 
                # relationships have a relationship name then a go term
                elif field == "relationship":
                    value = re.sub(r'(.+? .+?) .*', "\\1", value)
                    split_temp = re.split(r' ', value)
                    field = split_temp[0]
                    value = split_temp[1]    
                    print("x" + field + "x\tx" + value + "x")
                    go[current_id][field].append(value) 

    return go



# define a function to find all descendants of a GO term in the GO hierarchy:
def find_all_descendants(input_go_term, go):

    descendants = set()
    queue = []
    queue.append(input_go_term)
    while queue:
        node = queue.pop(0)
        if node in go and node not in descendants: # don't visit a second time
            node_children = go[node]['is_a']
    #        print(node_children)
            queue.extend(node_children)
            node_children = go[node]['part_of']
            queue.extend(node_children)
            node_children = go[node]['regulates']
            queue.extend(node_children)
            node_children = go[node]['positively_regulates']
            queue.extend(node_children)
            node_children = go[node]['negatively_regulates']
            queue.extend(node_children)
        descendants.add(node)

    return descendants 


if __name__=="__main__":
    main()
