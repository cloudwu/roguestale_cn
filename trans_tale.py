from googletrans import Translator
import codecs

#  "English.xml.trans.txt"
def just_log(fname, msg):
    f1_writer = codecs.open(fname, mode="a", encoding="utf-8")
    f1_writer.write(msg + "\n")
    f1_writer.close()

def file_read_all_lines_strip(file_name):
    lines = []
    with open(file_name, mode='r', encoding='utf-8') as read_file:
        for line in read_file:
            lines.append(line.replace("\n", "").replace("\r", "").strip())

    return lines


f_lines = file_read_all_lines_strip("English.xml.txt")
trnslator = Translator(service_urls=[
      'translate.google.cn',
    ])
f2_lines = file_read_all_lines_strip("English.xml.index.txt")
index = int( f2_lines[ f2_lines.__len__() -1])
print(index)
i = 0
for l in f_lines :
    i += 1
    just_log("English.xml.index.txt", str(i))
    if not str(l).__contains__("\"") :
        continue
    l1 = str(l).split("\"")[2]
    if i <= index:
        continue
    try:
        r1 = trnslator.translate(l1,src='en',dest='zh-CN')
        r2 = str(r1).split(',')[2].split('=')[1]
        print(r2)
        just_log("English.xml.trans1.txt",str(i)+"\t"+r2)
        just_log("English.xml.trans2.txt", str(l).split("\"")[0]+str(l).split("\"")[1] + " " + r2)
    except Exception as e1:
        print(l1)
        print(l)
        print(i)
        just_log("English.xml.trans2.txt",str(l))
        print(e1)
        break
        # 风紧 扯呼
    break

