from xml.dom import minidom
import os
import csv
SVGfiles = ("homo_sapiens.female", "homo_sapiens.male", "mus_musculus.male", "mus_musculus.female")

for organism in SVGfiles:
    print(organism)
    doc = minidom.parse(organism + ".svg")
    your_csv_file = open(organism + '_coords.tsv', 'w')
    wr = csv.writer(your_csv_file, delimiter='\t')
    
    for path in doc.getElementsByTagName('path'):
        if "outline" in path.getAttribute('id') or "LAYER_OUTLINE" in path.getAttribute('id') :
            wr.writerow([path.getAttribute('id') ,path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')]) 
        if path.getAttribute('id').startswith('UB'):
            wr.writerow([path.getElementsByTagName('title')[0].firstChild.nodeValue, path.getAttribute('d'), str('matrix(1,0,0,1,0,0)')])
        if path.parentNode.attributes['id'].value.startswith('UB'):
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
                            wr.writerow([path2.childNodes[1].attributes['id'].value, nodeVal,  path2.attributes['transform'].value])
                        else:
                            wr.writerow([path2.childNodes[1].attributes['id'].value, nodeVal, str('matrix(1,0,0,1,0,0)')])
                    else:
                        continue
                else:
                    continue
        else:
            continue
    for path in doc.getElementsByTagName('g'):
        if "LAYER_OUTLINE" in path.getAttribute('id') :
            print(path.getAttribute('id'))
            print(path.getAttribute('d'))
            node = path
            if len(node.childNodes[1].childNodes) >=1 :
                for child in node.childNodes[1].childNodes :
                    if "text" not in child.nodeName:
                        print(child.attributes['d'].value)
                        wr.writerow([path.getAttribute('id'), child.attributes['d'].value, str('matrix(1,0,0,1,0,0)')])
            else :
                wr.writerow([path.getAttribute('id'), node.childNodes[1].attributes['d'].value, str('matrix(1,0,0,1,0,0)')])
    for path in doc.getElementsByTagName('g'):
        if path.getAttribute('id').startswith('UB'):
            if "UBERON_0000992" in path.getAttribute('id') :
                node=path
                node.attributes['transform'].value
                node.childNodes[1].attributes['id'].value
                node.childNodes[3]
your_csv_file.close()