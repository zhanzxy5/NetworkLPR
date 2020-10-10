# Author: Xianyuan Zhan
# Date: 1/30/2016
# Reformat raw data to suitable format:
# Format: Plate ID | Hour | Min | Second | Travel Orientation | LaneID
# Output data into a folder specified by day and grouped by intersections

import os

# Data structures: this LPR_Entry is just for the old data format
class Raw_LPR_Entry:
    def __init__(self, entryLine):
        self.plate = entryLine.split(',')[0]
        self.day = entryLine.split(',')[3]
        self.hour = entryLine.split(',')[4]
        self.min = entryLine.split(',')[5]
        self.sec = entryLine.split(',')[6]
        self.intersection = entryLine.split(',')[7]
        self.dir = entryLine.split(',')[8]
        self.lane = entryLine.split(',')[9]

    def getPlate(self):
        return self.plate

    def getIntersection(self):
        return self.intersection

    def getDay(self):
        return self.day

    def formatLine(self):
        return self.plate + '\t' + self.hour + '\t' + self.min + '\t' + self.sec + '\t' + self.dir + '\t' + self.lane + '\n'

def reformatData(Dir, filename, day):
    input_f = open(Dir + filename, 'r')
    intersectionDict = {}
    header = "Plate ID\tHour\tMin\tSecond\tTravel Orientation\tLaneID\n"

    while 1:
        line = input_f.readline()
        if len(line) == 0:
            break

        lpr_entry = Raw_LPR_Entry(line)

        # # Comment out if keeping the wp entries
        # if lpr_entry.getPlate() == 'wp':
        #     continue

        if lpr_entry.getDay() == day:
            # Check intersection
            intersection = lpr_entry.getIntersection()
            if intersection not in intersectionDict.keys():
                # Create intersection file
                intersection_file = open(Dir + day + '/' + intersection + '.txt', 'w')
                intersectionDict[intersection] = intersection_file
                # write the header
                intersection_file.write(header)
            else:
                intersectionDict[intersection].write(lpr_entry.formatLine())

    input_f.close()
    for int_filename in intersectionDict.keys():
        intersectionDict[int_filename].close()
    print "Day:\t" + day + "\tObservable Intersection:"
    print intersectionDict.keys()


if __name__=='__main__': # For testing purpose
    # Dir = "C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/"
    Dir = "D:/Dropbox/China Camera Data/Network LPR/Data/New Data/latest_data_with_wp/"
    filename = "sampledata0328.csv"

    days = ["6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]

    day = "17"

    for day in days:
        directory = Dir + day + '/'
        if not os.path.exists(directory):
            os.makedirs(directory)
        reformatData(Dir, filename, day)

    '''
    # Intersection List
    intersectionList = ['1310000001', '1310000012', '1310000028', '1310000004', '1310000002', '1310000018', '1310000033', '1310000054',
     '1310000003', '1310000029', '1310000013', '1310000007', '1310000021', '1310000019', '1310000055', '1310000056',
     '1310000053', '1310000068', '1310000069', '1310000020', '1310000034', '1310000051']
    '''