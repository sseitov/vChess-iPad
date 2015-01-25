//
//  DBConverter.m
//  DBConverter
//
//  Created by Sergey Seitov on 7/1/10.
//  Copyright 2010 Progorod Ltd. All rights reserved.
//

#import "DBConverter.h"
#include <sqlite3.h>
#include <string>
#include <vector>
#include <boost/algorithm/string.hpp>
#include "game.h"

@implementation DBConverter

- (void)awakeFromNib {
	
	[progress setUsesThreadedAnimation:YES];
}

- (sqlite3*)createDatabase:(NSString*)dbPath {
	
	NSError *error;
	[[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
	BOOL success = [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
	if (!success) {
		return nil;
	}
	
	sqlite3 *db = NULL;
	if (sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
		sqlite3_close(db);
		return nil;
	}
	
	sqlite3_stmt *pStmt;
	NSString *sql = @"\
	CREATE TABLE games (id integer PRIMARY KEY AUTOINCREMENT, \
	Event varchar(64), \
	Site varchar(64), \
	Date varchar(16), \
	Round varchar(4), \
	White varchar(64), \
	Black varchar(64), \
	Result varchar(8), \
	ECO varchar(8), \
	PGN text)";
	
	if(sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, NULL) != SQLITE_OK) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		sqlite3_close(db);
		return nil;
	}
	sqlite3_step(pStmt);
	sqlite3_finalize(pStmt);
	
	return db;
}

- (BOOL)insertGame:(NSDictionary*)header pgn:(NSString*)pgn intoDB:(sqlite3*)db {
	
	sqlite3_stmt *pStmt;
	NSString *sql = @"insert into games(Event, Site, Date, Round, White, Black, Result, ECO, PGN) values(?, ?, ?, ?, ?, ?, ?, ?, ?)";
	if(sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, NULL) != SQLITE_OK) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		return NO;
	}
	
	NSString *event = [header valueForKey:@"Event"];
	if (!event) event = @"";
	int result = sqlite3_bind_text(pStmt, 1, [event UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 1");
	
	NSString *site = [header valueForKey:@"Site"];
	if (!site) site = @"";
	result = sqlite3_bind_text(pStmt, 2, [site UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 2");
	
	NSString *date = [header valueForKey:@"Date"];
	if (!date) date = @"";
	result = sqlite3_bind_text(pStmt, 3, [date UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 3");
	
	NSString *round = [header valueForKey:@"Round"];
	if (!round) round = @"";
	result = sqlite3_bind_text(pStmt, 4, [round UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 4");
	
	NSString *white = [header valueForKey:@"White"];
	if (!white) white = @"";
	result = sqlite3_bind_text(pStmt, 5, [white UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 5");
	
	NSString *black = [header valueForKey:@"Black"];
	if (!black) black = @"";
	result = sqlite3_bind_text(pStmt, 6, [black UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 6");
	
	NSString *Result = [header valueForKey:@"Result"];
	if (!Result) Result = @"";
	result = sqlite3_bind_text(pStmt, 7, [Result UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 7");
	
	NSString *ECO = [header valueForKey:@"ECO"];
	if (!ECO) ECO = @"";
	result = sqlite3_bind_text(pStmt, 8, [ECO UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 8");
	
	result = sqlite3_bind_text(pStmt, 9, [pgn UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 9");
	
	if(sqlite3_step(pStmt) != SQLITE_DONE) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		return NO;
	} else {
		sqlite3_finalize(pStmt);
		return YES;
	}
}
- (BOOL)appendGame:(NSString*)header pgn:(NSString*)pgn intoDB:(sqlite3*)db {
	
	std::string headerStr([header UTF8String]);
	std::vector<std::string> headerLines;
	boost::split(headerLines, headerStr, boost::is_any_of("\r\n"));
	NSMutableDictionary *gameHeader = [NSMutableDictionary dictionary];
	for (int i=0; i<headerLines.size(); i++) {
		std::string line = headerLines[i];
		if (line.find('%') == 0) {
			continue;
		}
		if (line.size() < 1) continue;
		std::vector<std::string> linePair;
		boost::split(linePair, line, boost::is_any_of("[]\""));
		std::string key = linePair[1];
		std::vector<std::string> keyPair;
		boost::split(keyPair, key, boost::is_any_of(" "));
		std::string val = linePair[2];
		[gameHeader setValue:[NSString stringWithUTF8String:val.data()]
					forKey:[NSString stringWithUTF8String:keyPair[0].data()]];
	}
	
	std::string pgnStr([pgn UTF8String]);
	std::vector<std::string> turns;
	boost::split(turns, pgnStr, boost::is_any_of(" \r\n"));
	std::string result;
	for (int i=0; i<turns.size(); i++) {
		if (turns[i].size() < 1) continue;
		std::vector<std::string> turnPair;
		boost::split(turnPair, turns[i], boost::is_any_of("."));
		if (turnPair.size() > 1) {
			result += turnPair[1];
		} else {
			result += turnPair[0];
		}
		result += " ";
	}
	NSString *gamePGN = [NSString stringWithUTF8String:result.data()];
	try {
		vchess::Game* game = new vchess::Game([gamePGN UTF8String], "White", "Black");
		printf("SUCCESS\n");
		delete game;
		return [self insertGame:gameHeader pgn:gamePGN intoDB:db];
	} catch (std::exception& e) {
		printf("ERROR GAME: %s\n", e.what());
		return NO;
	}	
}

- (IBAction)openPGN:(id)sender {
	
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setAllowsMultipleSelection:YES];
	[op setAllowedFileTypes:[NSArray arrayWithObject:@"pgn"]];
    if ([op runModal] != NSOKButton)
		return;
	
	[progress startAnimation:self];
	
	NSArray *urls = [op URLs];
	
	for (int i=0; i<[urls count]; i++) {
		NSString *fileName = [[urls objectAtIndex:i] path];		
		NSString *dbName = [fileName stringByReplacingOccurrencesOfString:@".pgn" withString:@".sqlite"];
		sqlite3* db = [self createDatabase:dbName];
		if (!db) {
			NSLog(@"Error create database %@", dbName);
			break;
		}
		NSError *error = NULL;
		NSString *gameText = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:&error];
		if (error) {
			NSLog(@"ERROR: %@", [error localizedDescription]);
			break;
		}
		NSArray *elements = [gameText componentsSeparatedByString:@"\r\n\r\n"];
		if (!elements || elements.count < 2) {
			elements = [gameText componentsSeparatedByString:@"\n\n"];
		}
		
		NSEnumerator *enumerator = [elements objectEnumerator];
		NSString *header;
		while (header = [enumerator nextObject]) {
			NSString *pgn = [enumerator nextObject];
			if (pgn) {
				[self appendGame:header pgn:pgn intoDB:db];
			}
		}
		
		sqlite3_close(db);
	}

	[progress stopAnimation:self];
}

@end
