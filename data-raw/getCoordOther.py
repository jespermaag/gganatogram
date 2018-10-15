from xml.dom import minidom
import os
import csv
import re 
SVGfiles = os.listdir('svg')

for organism in SVGfiles:
    organism = re.sub(".svg", "", organism)
    print(organism)
    doc = minidom.parse('svg/' + organism + ".svg")
    your_csv_file = open('other/' + organism + '_coords.tsv', 'w')
    wr = csv.writer(your_csv_file, delimiter='\t')
    
    for path in doc.getElementsByTagName('path'):
        if "outline" in path.getAttribute('id') or "LAYER_OUTLINE" in path.getAttribute('id') :
            wr.writerow([path.getAttribute('id') ,path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')]) 
        if path.getAttribute('id').startswith('UB') or path.getAttribute('id').startswith('PO'):
            wr.writerow([path.getElementsByTagName('title')[0].firstChild.nodeValue, path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')])
        if path.parentNode.attributes['id'].value.startswith('UB') or path.getAttribute('id').startswith('PO'):
            if "transform" not in list(path.parentNode.attributes.keys()): 
                wr.writerow([path.parentNode.attributes['id'].value, path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')])
    for path2 in doc.getElementsByTagName('g')[1:]:
        if len(path2.childNodes) >0 :
            for node in path2.childNodes:
                if "text" not in node.nodeName:
                    print('ok')
                    print(node.nodeName)
                    print(node.attributes.keys())
                    if 'd' in list(node.attributes.keys()): 
                        nodeVal = node.attributes['d'].value
                        if 'transform' in list(path2.attributes.keys()): 
                            wr.writerow([path2.attributes['id'].value, nodeVal,  path2.attributes['transform'].value])
                        else:
                            wr.writerow([path2.attributes['id'].value, nodeVal, str('matrix(1,0,0,1,0,0)')])
                    else:
                        continue
                else:
                    continue
        else:
            continue
    for path in doc.getElementsByTagName('g'):
        print(path.getAttribute('id') )
        if "LAYER_OUTLINE" in path.getAttribute('id') :
            print(path.getAttribute('id'))
            #print(path.getAttribute('d'))
            node = path
            if len(node.childNodes) >=1 :
                for child in node.childNodes :
                    if "path" in child.nodeName:
                        wr.writerow([path.getAttribute('id'), child.attributes['d'].value, str('matrix(1,0,0,1,0,0)')])
    for path in doc.getElementsByTagName('g'):
        if path.getAttribute('id').startswith('UB') or path.getAttribute('id').startswith('PO'):
            if "UBERON_0000992" in path.getAttribute('id') :
                node=path
                node.attributes['transform'].value
                node.childNodes[1].attributes['id'].value
                node.childNodes[3]
your_csv_file.close()