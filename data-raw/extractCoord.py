from xml.dom import minidom
import os
import csv
#SVGfiles = ("homo_sapiens.female", "homo_sapiens.male", "rattus_norvegicus", "mus_musculus.male", "mus_musculus.female")
#
#for organism in SVGfiles:
#    doc = minidom.parse(organism + ".svg")  # parseString also exists
#    your_csv_file = open(organism + '_coords.tsv', 'w')
#    wr = csv.writer(your_csv_file, delimiter='\t')
#    for path in doc.getElementsByTagName('path'):
#        if "outline" in path.getAttribute('id') or "LAYER_OUTLINE" in path.getAttribute('id') :
#            wr.writerow([path.getAttribute('id') ,path.getAttribute('d')]) 
#
#your_csv_file.close()
#
organism="homo_sapiens.female"
doc = minidom.parse(organism + ".svg")
your_csv_file = open(organism + '_coords.tsv', 'w')
wr = csv.writer(your_csv_file, delimiter='\t')

#for path in doc.getElementsByTagName('path'):
#    if len(path.childNodes) >0 :
#        wr.writerow([path.childNodes[1].attributes['id'].value, path.attributes['d'].value])
for path in doc.getElementsByTagName('path'):
    if "outline" in path.getAttribute('id') or "LAYER_OUTLINE" in path.getAttribute('id') :
        wr.writerow([path.getAttribute('id') ,path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')]) 
    if path.getAttribute('id').startswith('UB'):
        wr.writerow([path.getElementsByTagName('title')[0].firstChild.nodeValue, path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')])
    if path.parentNode.attributes['id'].value.startswith('UB'):
        if "transform" not in list(path.parentNode.attributes.keys()): 
            wr.writerow([path.parentNode.attributes['id'].value, path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')])
        #if "transform"  in list(path.parentNode.attributes.keys()): 
         #   wr.writerow([path.parentNode.attributes['id'].value, path.getAttribute('d')])


for path in doc.getElementsByTagName('g')[1:]:
    if len(path.childNodes) >0 :
        for node in path.childNodes:
            if "text" not in node.nodeName:
                print(node.nodeName)
                print(node.attributes.keys())
                if 'd' in list(node.attributes.keys()): 
                    nodeVal = node.attributes['d'].value
                    #if 'transform' in list(node.attributes.keys()): 
                    #    nodeTrans = node.attributes['transform'].value
                    #   wr.writerow([path.childNodes[1].attributes['id'].value, nodeVal,  nodeTrans])
                    #else:
                    if 'transform' in list(path.attributes.keys()): 
                        wr.writerow([path.childNodes[1].attributes['id'].value, nodeVal,  path.attributes['transform'].value])
                    else :
                        wr.writerow([path.childNodes[1].attributes['id'].value, nodeVal, str('matrix(1,0,0,1,0,0)')])


for path in doc.getElementsByTagName('g'):
    if "LAYER_OUTLINE" in path.getAttribute('id') :
        print(path.getAttribute('id'))
        print(path.getAttribute('d'))
        node = path
        for child in node.childNodes[1].childNodes :
            if "text" not in child.nodeName:
                wr.writerow([path.getAttribute('id'), child.attributes['d'].value, str('matrix(1,0,0,1,0,0)')])


your_csv_file.close()
