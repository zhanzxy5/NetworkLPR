# Author: Xianyuan Zhan
# Date: 1/30/2016
# Extract travel time by matching license plate

import os
import operator
from multiprocessing import Process
from NetworkData import *

class Formatted_LPR_Entry:
    def __init__(self, entryLine):
        self.plate = entryLine.split('\t')[0]
        self.hour = int(entryLine.split('\t')[1])
        self.min = int(entryLine.split('\t')[2])
        self.sec = int(entryLine.split('\t')[3])
        self.dir = int(entryLine.split('\t')[4])
        self.lane = int(entryLine.split('\t')[5])
        self.time = 3600 * self.hour + 60 * self.min + self.sec

class TT_Entry:
    def __init__(self, lpr_entry, matched_time):
        self.lpr_entry = lpr_entry
        self.TT = matched_time - lpr_entry.time
        self.depTime = lpr_entry.time
        self.outputline = str(lpr_entry.time) + '\t' + str(matched_time) + '\t' + str(matched_time - lpr_entry.time) + '\n'

def loadIntersectionData(Dir, day, intersection):
    input_f = open(Dir + day + '/' + intersection + '.txt')

    # create two data structures, first a list of LPR entries, second, a dictionary mapping all license plates to
    LPR_Entry_List = []
    PlateDict = {}
    PlateEntryDict = {}

    # Escape the header
    line = input_f.readline()

    while 1:
        line = input_f.readline()
        if len(line) == 0:
            break

        lpr_entry = Formatted_LPR_Entry(line)
        LPR_Entry_List.append(lpr_entry)
        if lpr_entry.plate != "wp":
            if lpr_entry.plate not in PlateDict.keys():
                PlateDict[lpr_entry.plate] = [lpr_entry.time]
                PlateEntryDict[lpr_entry.plate] = [lpr_entry]
            else:
                PlateDict[lpr_entry.plate].append(lpr_entry.time)
                PlateEntryDict[lpr_entry.plate].append(lpr_entry)

    input_f.close()
    return {"Entries":LPR_Entry_List, "PlateDict":PlateDict, "PlateEntryDict": PlateEntryDict}

def extractLinkTravelTime(Dir, day, link, match_threshold):
    print "Processing Link: " + link.ID
    if link.type == 1:
        linkTT_f = open(Dir + day + "/LinkTT/" + link.ID  + '.txt', 'w')
        outputline = "Start Time\tEnd Time\tTravel Time\n"
        linkTT_f.write(outputline)
        linkTTList = []

        fromInt = link.fromInt
        toInt = link.toInt

        fromIntData = loadIntersectionData(Dir, day, fromInt)
        toIntData = loadIntersectionData(Dir, day, toInt)

        for lpr_entry in fromIntData["Entries"]:
            if lpr_entry.dir == link.dir: # The LPR entry direction should be the same as the link direction
                if lpr_entry.plate in toIntData["PlateDict"].keys():
                    # check the list of the times and see if any satisfy the requirement
                    for time in toIntData["PlateDict"][lpr_entry.plate]:
                        if lpr_entry.time < time and abs(time - lpr_entry.time) < match_threshold:
                            if time - lpr_entry.time > link.len / 22.5: # speed should not exceeds 72km/h
                                # Found an matched LPR entry
                                linkTTList.append(TT_Entry(lpr_entry, time))
                                break

        # Sort the lists according to the start time
        sorted_linkTT = sorted(linkTTList, key=lambda x: x.depTime)
        for i in range(len(sorted_linkTT)):
            # Filtering out unreasonable TTs (the one larger than 3 times of the average of previous and after entries)
            if i > 0 and i < len(sorted_linkTT) - 1:
                checkSum = sorted_linkTT[i-1].TT + sorted_linkTT[i+1].TT
                if sorted_linkTT[i].TT < 1.25 * checkSum:
                    linkTT_f.write(sorted_linkTT[i].outputline)
                    # In order to not avoid later filtering, replace the problematic entry with the checkSum
                else:
                    sorted_linkTT[i].TT = checkSum
            else:
                linkTT_f.write(sorted_linkTT[i].outputline)

        # for item in sorted_linkTT:
        #     linkTT_f.write(item[1])
        linkTT_f.close()

        return link.ID
    else:
        return "NA"

def processLinkTT(Dir, day, linkDict, match_threshold):
    print "Processing Day: " + day
    directory = Dir + day + "/LinkTT/"
    if not os.path.exists(directory):
        os.makedirs(directory)
    resolvedLinks = []
    for linkID in linkDict.keys():
        retID = extractLinkTravelTime(Dir, day, linkDict[linkID], match_threshold)
        if retID != "NA":
            resolvedLinks.append(retID)
    print resolvedLinks

def extractPathTravelTime(Dir, day, path, linkDict, match_threshold):
    print "Processing Link: " + path.ID
    pathTT_f = open(Dir + day + "/PathTT/" + path.ID + '.txt', 'w')
    outputline = "Start Time\tEnd Time\tTravel Time\n"
    pathTT_f.write(outputline)
    pathTTList = []
    pathDist = 0.0
    for i in range(path.pathLen):
        pathDist += linkDict[path.path[i]].len

    fromInt = path.fromInt
    toInt = path.toInt

    fromIntData = loadIntersectionData(Dir, day, fromInt)
    toIntData = loadIntersectionData(Dir, day, toInt)

    for lpr_entry in fromIntData["Entries"]:
        if lpr_entry.dir in path.fromObs:  # The LPR entry direction should be the same as the link direction
            if lpr_entry.plate in toIntData["PlateEntryDict"].keys():
                # check the list of the times and see if any satisfy the requirement
                for to_entry in toIntData["PlateEntryDict"][lpr_entry.plate]:
                    if to_entry.dir == path.toObs:
                        if lpr_entry.time < to_entry.time and abs(to_entry.time - lpr_entry.time) < match_threshold * path.pathLen:
                            if to_entry.time - lpr_entry.time > pathDist / 22.5:  # speed should not exceeds 81km/h
                                # Found an matched LPR entry
                                pathTTList.append(TT_Entry(lpr_entry, to_entry.time))
                                break

    # Sort the lists according to the start time
    sorted_pathTT = sorted(pathTTList, key=lambda x: x.depTime)
    for i in range(len(sorted_pathTT)):
        # Filtering out unreasonable TTs (the one larger than 3 times of the average of previous and after entries)
        if i > 0 and i < len(sorted_pathTT) - 1:
            checkSum = sorted_pathTT[i - 1].TT + sorted_pathTT[i + 1].TT
            if sorted_pathTT[i].TT < 1.25 * checkSum:
                pathTT_f.write(sorted_pathTT[i].outputline)
                # In order to not avoid later filtering, replace the problematic entry with the checkSum
            else:
                sorted_pathTT[i].TT = checkSum
        else:
            pathTT_f.write(sorted_pathTT[i].outputline)

    # for item in sorted_linkTT:
    #     linkTT_f.write(item[1])
    pathTT_f.close()

    return path.ID

def processPathTT(Dir, day, pathDict, linkDict, match_threshold):
    print "Processing Day: " + day
    directory = Dir + day + "/PathTT/"
    if not os.path.exists(directory):
        os.makedirs(directory)
    resolvedPaths = []
    for pathID in pathDict.keys():
        retID = extractPathTravelTime(Dir, day, pathDict[pathID], linkDict, match_threshold)
        if retID != "NA":
            resolvedPaths.append(retID)
    print resolvedPaths


if __name__=='__main__': # For testing purpose
    Dir = "D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/"
    link_filename = "D:/Dropbox/China Camera Data/Network LPR/Data/network data/link_data_small_net.csv"
    intersection_filename = "D:/Dropbox/China Camera Data/Network LPR/Data/network data/intersection_data_small_net.csv"
    path_filename = "D:/Dropbox/China Camera Data/Network LPR/Data/network data/path_data_small_net.csv"

    match_threshold = 300
    intersectionDict = loadIntersections(intersection_filename)
    linkDict = loadLinks(link_filename, intersectionDict)

    mode = 1 # 1- extract link data; 2- extract path data


    if mode == 1:
        p0 = Process(target=processLinkTT, args=(Dir, "11", linkDict, match_threshold))
        p0.start()

        p1 = Process(target = processLinkTT, args= (Dir, "12", linkDict, match_threshold))
        p1.start()

        p2 = Process(target=processLinkTT, args=(Dir, "13_problematic", linkDict, match_threshold))
        p2.start()

        p3 = Process(target=processLinkTT, args=(Dir, "14", linkDict, match_threshold))
        p3.start()

        p4 = Process(target=processLinkTT, args=(Dir, "15", linkDict, match_threshold))
        p4.start()

        p5 = Process(target=processLinkTT, args=(Dir, "16", linkDict, match_threshold))
        p5.start()

        p6= Process(target=processLinkTT, args=(Dir, "17", linkDict, match_threshold))
        p6.start()
    else:
        pathDict = loadPaths(path_filename)
        '''
        p1 = Process(target=processPathTT, args=(Dir, "11", pathDict, linkDict, match_threshold))
        p1.start()
        '''
        p1 = Process(target=processPathTT, args=(Dir, "12", pathDict, linkDict, match_threshold))
        p1.start()

        p2 = Process(target=processPathTT, args=(Dir, "13_problematic", pathDict, linkDict, match_threshold))
        p2.start()

        p3 = Process(target=processPathTT, args=(Dir, "14", pathDict, linkDict, match_threshold))
        p3.start()

        p4 = Process(target=processPathTT, args=(Dir, "15", pathDict, linkDict, match_threshold))
        p4.start()

        p5 = Process(target=processPathTT, args=(Dir, "16", pathDict, linkDict, match_threshold))
        p5.start()

        p6 = Process(target=processPathTT, args=(Dir, "17", pathDict, linkDict, match_threshold))
        p6.start()

    # resolvedLinks = ['5', '6', '11', '12', '15', '24', '25', '26', '27', '28', '29', '30', '55', '57', '66', '67', '93', '94', '95', '96', '103', '104', '105']
