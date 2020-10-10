# Author: Xianyuan Zhan
# Date: 11/3/2016
# Check the direction and observability of the LPR network

# Helper methods:
# Convert the LPR entry time into seconds
def convertToSec(LPR_entry):
    return LPR_entry.hour * 3600 + LPR_entry.min * 60 + LPR_entry.sec

# Data structures: this LPR_Entry is just for the old data format
class LPR_Entry:
    def __init__(self, entryLine):
        self.plate = entryLine.split('\t')[0]
        time = entryLine.split('\t')[2]
        self.hour = int(time.split(':')[0])
        self.min = int(time.split(':')[1])
        self.sec = int(float(time.split(':')[2]))
        self.intersection = entryLine.split('\t')[3]
        self.dir = int(entryLine.split('\t')[4])
        self.lane = int(entryLine.split('\t')[5])
        self.timeInSec = self.hour * 3600 + self.min * 60 + self.sec

class IntersectionData:
    def __init__(self, intersectionID):
        self.ID = intersectionID
        self.observability = {1: False, 2: False, 3: False, 4: False}
        self.dirCount = {1: 0, 2: 0, 3: 0, 4: 0} # count of observations for each direction
        self.matchCount = {1: {}, 2: {}, 3: {}, 4: {}} # matched intersection ID and corresponding count for each direction
        self.dirData = {1: [], 2: [], 3: [], 4:[]}
        self.lane = {1: [], 2: [], 3: [], 4:[]}

    def addEntry(self, LPR_entry):
        if LPR_entry.intersection == self.ID:
            self.observability[LPR_entry.dir] = True
            self.dirCount[LPR_entry.dir] += 1
            self.dirData[LPR_entry.dir].append(LPR_entry)
            if LPR_entry.lane not in self.lane[LPR_entry.dir]:
                self.lane[LPR_entry.dir].append(LPR_entry.lane)

    def updateMatching(self, tarIntersection, usedDir):
        if tarIntersection != self.ID:
            if tarIntersection not in self.matchCount[usedDir].keys():
                self.matchCount[usedDir][tarIntersection] = 1
            else:
                self.matchCount[usedDir][tarIntersection] += 1

    def printIntersection(self):
        outputStr = self.ID + ','
        # Observability
        for i in range(4):
            if self.observability[i+1]:
                outputStr = outputStr + '1,'
            else:
                outputStr = outputStr + '0,'
        # Direction counts
        for i in range(4):
            outputStr = outputStr + str(self.dirCount[i+1]) + ','

        # Output matching results: we only print out thetarget intersection with the maximum number of matching
        for i in range(4):
            if self.observability[i+1]:
                if len(self.matchCount[i+1].keys()) >0:
                    maxCount = 0
                    maxKey = ""
                    for key in self.matchCount[i+1].keys():
                        if self.matchCount[i+1][key] > maxCount:
                            maxCount = self.matchCount[i+1][key]
                            maxKey = key
                    outputStr = outputStr + str(maxKey) + ',' + str(maxCount) + ','
                else:
                    # No matching found, unknown
                    outputStr = outputStr + 'Unknown,0,'
            else:
                # If the direction is not observed, then not possible to have target intersection
                outputStr = outputStr + 'NA,0,'

        # Monitored lane data for each intersection
        for i in range(4):
            outputStr = outputStr + str(len(self.lane[i+1])) + ','

            count = 0
            for lane in sorted(self.lane[i+1]):
                outputStr = outputStr + str(lane)
                outputStr = outputStr + ','
                count += 1

            for j in range(4-count):
                outputStr = outputStr + '-1,'

        return outputStr + '\n'



# Major functions that do the work
def intersectionCheck(LPR_filename, network_check_filename, match_threshold):
    LPRfile = open(LPR_filename, 'r')
    checkFile = open(network_check_filename, 'w')

    # LPR data list: store all the data
    LPR_data = []
    # Intersection dictionary
    intersection_dict = {}
    # License plate dictionary: key as the license plate, data are the LPR entries
    plate_dict = {}

    count = 0

    while 1:
        entryLine = LPRfile.readline()
        if len(entryLine) == 0:
            break

        try:
            dataEntry = LPR_Entry(entryLine)
            LPR_data.append(dataEntry)

            if dataEntry.plate not in plate_dict.keys():
                plate_dict[dataEntry.plate] = [dataEntry]
            plate_dict[dataEntry.plate].append(dataEntry)

            if dataEntry.intersection not in intersection_dict.keys():
                intersection_dict[dataEntry.intersection] = IntersectionData(dataEntry.intersection)
            intersection_dict[dataEntry.intersection].addEntry(dataEntry)

            count += 1

            if count % 10000 == 0:
                print "Analyzed " + str(count) + " LPR entries"

        except IndexError:
            print entryLine

    LPRfile.close()

    # Util now, we are done with converting all the data
    # Next, we need to analyze the matching: we match upon the license plate, use the time stamp to decide A->B or B->A
    print "Now analyzing matching:"
    for plate in plate_dict.keys():
        if len(plate_dict[plate]) == 1:
            continue
        plateData = plate_dict[plate]
        # sort the entries based on occurrence time
        plateData.sort(key = lambda x: x.timeInSec)

        # Verify consecutive entries
        for i in range(len(plateData) - 1):
            if plateData[i+1].intersection != plateData[i].intersection:
                if plateData[i+1].timeInSec - plateData[i].timeInSec <= match_threshold:
                    intersection_dict[plateData[i].intersection].updateMatching(plateData[i+1].intersection, plateData[i].dir)

    # output the intersection checking data
    for intersection in intersection_dict.keys():
        outputline = intersection_dict[intersection].printIntersection()
        # print outputline
        checkFile.write(outputline)

    checkFile.close()

if __name__=='__main__': # For testing purpose
    match_threshold = 300

    network_check_filename = "network_check_15.csv"
    LPR_filename = "C:/Temp/Dropbox/China Camera Data/Network LPR/Data/LPR data/15_data.txt"
    intersectionCheck(LPR_filename, network_check_filename, match_threshold)
