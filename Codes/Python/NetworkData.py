# Author: Xianyuan Zhan
# Date: 11/6/2016
# Data structure that loads the network topology data

class Intersection:
    def __init__(self, intersectionID):
        self.ID = intersectionID
        self.alterID = 0
        self.observability = {1: False, 2: False, 3: False, 4: False}
        self.dirIntersection = {1: 'NA', 2: 'NA', 3: 'NA', 4: 'NA'} # Downstream intersection in the main direction
        self.leftIntersection = {1: 'NA', 2: 'NA', 3: 'NA', 4: 'NA'} # Downstream intersection by performing left turning movement
        self.rightIntersection = {1: 'NA', 2: 'NA', 3: 'NA', 4: 'NA'}  # Downstream intersection by performing right turning movement
        self.nLanes = {1: 0, 2: 0, 3: 0, 4: 0}  # We only care about the lanes that observable in LPR data
        self.lanes = {1: [], 2: [], 3: [], 4: []} # Observed lane IDs for each direction

    def addIntersectionInfo(self, line):
        self.alterID = int(line.split(',')[0])
        self.dirIntersection[1] = line.split(',')[4]
        self.dirIntersection[2] = line.split(',')[5]
        self.dirIntersection[3] = line.split(',')[6]
        self.dirIntersection[4] = line.split(',')[7]

        # Resolve the left and right turning downstream intersection
        for i in range(4):
            if i + 2 <= 4:
                self.leftIntersection[i + 1] = self.dirIntersection[i + 2]
            else:
                self.leftIntersection[i + 1] = self.dirIntersection[1]

            if i > 0:
                self.rightIntersection[i + 1] = self.dirIntersection[i]
            else:
                self.rightIntersection[i + 1] = self.dirIntersection[4]

        # Observability
        self.observability[1] = int(line.split(',')[8])
        self.observability[2] = int(line.split(',')[9])
        self.observability[3] = int(line.split(',')[10])
        self.observability[4] = int(line.split(',')[11])

        # Lane data
        for i in range(4):
            self.nLanes[i + 1] = int(line.split(',')[12 + 5 * i])
            for j in range(4):
                lane = int(line.split(',')[13 + 5 * i + j])
                if lane > 0:
                    self.lanes[i + 1].append(lane)


class Link:
    def __init__(self, linkID):
        self.ID = linkID
        self.alterID = 0
        self.fromInt = 'NA'
        self.toInt = 'NA'
        self.toLeftInt = 'NA'
        self.toRightInt = 'NA'
        self.type = 0
        self.dir = 0
        self.len = 0.0
        self.endNlanes = -1 # Number of lanes at the end of the road (LPR monitored only. -1 if unknown)

    def addLinkInfo(self, line, intersectionDict):
        self.alterID = int(line.split(',')[0])
        self.fromInt = line.split(',')[2]
        self.toInt = line.split(',')[3]
        self.type = int(line.split(',')[4])
        self.dir = int(line.split(',')[5])
        self.len = float(line.split(',')[6])

        self.toLeftInt = intersectionDict[self.toInt].leftIntersection[self.dir]
        self.toRightInt = intersectionDict[self.toInt].rightIntersection[self.dir]

        # Next resolve number of monitored lanes at downstream intersection
        if intersectionDict[self.toInt].nLanes[self.dir] > 0:
            self.endNlanes = intersectionDict[self.toInt].nLanes[self.dir]

class Path:
    def __init__(self, line):
        line = line.rstrip('\n')
        self.ID = line.split(',')[0]
        self.fromInt = line.split(',')[1]
        self.toInt = line.split(',')[2]
        obsLine = line.split(',')[3]
        self.fromObs = []
        if '1' in obsLine:
            self.fromObs.append(1)
        if '2' in obsLine:
            self.fromObs.append(2)
        if '3' in obsLine:
            self.fromObs.append(3)
        if '4' in obsLine:
            self.fromObs.append(4)
        self.toObs = int(line.split(',')[4])
        self.pathLen = int(line.split(',')[5])
        self.path = []
        for i in range(self.pathLen):
            self.path.append(line.split(',')[i + 6])

        print self.ID + '\t' + self.fromInt + '\t' + self.toInt + '\t' + str(self.fromObs) + '\t' + str(self.toObs) + '\t' + str(self.pathLen) + '\t' + str(self.path)

# Load the intersection data
def loadIntersections(intersection_filename):
    intFile = open(intersection_filename, 'r')

    intersectionDict = {}

    # Escape header
    line = intFile.readline()
    while 1:
        line = intFile.readline()
        if len(line) == 0:
            break

        intID = line.split(',')[1]
        intEntry = Intersection(intID)
        intEntry.addIntersectionInfo(line)
        intersectionDict[intID] = intEntry

    intFile.close()

    return intersectionDict

# Load the link data
def loadLinks(link_filename, intersectionDict):
    linkFile = open(link_filename, 'r')

    linkDict = {}

    # Escape header
    line = linkFile.readline()
    while 1:
        line = linkFile.readline()
        if len(line) == 0:
            break

        linkID = line.split(',')[1]
        linkEntry = Link(linkID)
        linkEntry.addLinkInfo(line, intersectionDict)
        linkDict[linkID] = linkEntry

    linkFile.close()

    return linkDict

# Load the path data
def loadPaths(path_filename):
    pathFile = open(path_filename, 'r')
    pathDict = {}

    # Escape header
    line = pathFile.readline()
    while 1:
        line = pathFile.readline()
        if len(line) == 0:
            break
        pathEntry = Path(line)
        pathDict[pathEntry.ID] = pathEntry

    pathFile.close()
    return pathDict

# Load the network as a nested dictionary
def buildNetwork(linkDict):
    adjMat = {}
    for linkID in linkDict.keys():
        link = linkDict[linkID]
        if link.fromInt not in adjMat.keys():
            adjMat[link.fromInt] = {link.toInt: linkID}
        else:
            adjMat[link.fromInt][link.toInt] = linkID

    return adjMat


if __name__=='__main__': # For testing purpose
    intersection_filename = "C:/Temp/Dropbox/China Camera Data/Network LPR/Data/network data/intersection_data_small_net.csv"
    link_filename =  "C:/Temp/Dropbox/China Camera Data/Network LPR/Data/network data/link_data_small_net.csv"

    intersectionDict = loadIntersections(intersection_filename)
    linkDict = loadLinks(link_filename, intersectionDict)
    adjMat = buildNetwork(linkDict)

    print adjMat