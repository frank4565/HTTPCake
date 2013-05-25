//
//  HCAppDelegate.m
//  HTTPCake
//
//  Created by Cheng Junlu on 5/24/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "HCAppDelegate.h"

@interface HCAppDelegate () <NSTableViewDataSource, NSTableViewDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableArray *parametersTable;
@end

@implementation HCAppDelegate

- (NSMutableArray *)parametersTable
{
    if (!_parametersTable) {
        _parametersTable = [[NSMutableArray alloc] init];
    }
    return _parametersTable;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.responseHeadersTextView.font = [NSFont fontWithName:@"Monaco" size:12.0f];
    
    self.parametersTableView.dataSource = self;
}

- (IBAction)onGet:(NSButton *)sender
{
    [self _makeRequestOfMethod:@"GET"];
}

- (IBAction)onPost:(id)sender
{
    [self _makeRequestOfMethod:@"POST"];
}

- (void)_makeRequestOfMethod:(NSString *)method
{
    // Append http if it's not there
    NSString *urlString = self.urlTextField.stringValue;
	if (![urlString hasPrefix:@"http"] && ![urlString hasPrefix:@"https"]) {
		urlString = [[NSString alloc] initWithFormat:@"http://%@", urlString];
		[self.urlTextField setStringValue:urlString];
	}
    NSLog(@"URL = %@", urlString);
    
    NSString *urlEscaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = nil;
	NSMutableURLRequest *request = nil;
    NSMutableString *parametersString = nil;
    NSData *body = nil;
    
    //	NSString * headerfield  = @"application/x-www-form-urlencoded";
	
    //	[request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    
	if(self.parametersTable.count > 0)
	{
        parametersString = [[NSMutableString alloc] init];
		for(NSDictionary *row in self.parametersTable)
		{
			NSString *key   = row[kParametersKey];
			NSString *value = row[kParametersValue];
			
			if(parametersString.length > 0)
				[parametersString appendString:@"&"];
			
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 			value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
			[parametersString appendString:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], value]];
		}
	}
    
    if ([method isEqualToString:@"GET"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlEscaped, parametersString]];
    } else if ([method isEqualToString:@"POST"]) {
        url = [NSURL URLWithString:urlEscaped];
        body = [parametersString dataUsingEncoding:NSUTF8StringEncoding];
    }
	
    request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    [request setHTTPBody:body];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (!connection) {
        NSLog(@"Could not establish connection.");
    }
}
#pragma mark - Parameters

NSString * const kParametersKey = @"Parameters Name";
NSString * const kParametersValue = @"Parameters Value";

- (IBAction)addParametersRow:(id)sender
{
    NSDictionary *row = @{kParametersKey : @"Key", kParametersValue : @"Value"};
    [self.parametersTable addObject:row];
    [self.parametersTableView reloadData];
    [self.parametersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(self.parametersTable.count - 1)] byExtendingSelection:NO];
    [self.parametersTableView editColumn:0 row:(self.parametersTable.count - 1) withEvent:nil select:YES];
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger count = 0;
    
    if (tableView == self.parametersTableView) {
        count = self.parametersTable.count;
    }
    
    return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id object = nil;
    
    if (tableView == self.parametersTableView) {
        object = self.parametersTable[row][tableColumn.identifier];
    }
    
    return object;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSMutableDictionary *dic = nil;
    if (tableView == self.parametersTableView) {
        dic = [self.parametersTable[row] mutableCopy];
        if (!dic) {
            dic = [[NSMutableDictionary alloc] init];
        }
        dic[tableColumn.identifier] = object;
        self.parametersTable[row] = dic;
    }
}

#pragma mark - URL Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Did receive repsonse.");
    
    NSMutableString *headers = [[NSMutableString alloc] init];
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
	[headers appendFormat:@"HTTP %ld %@\n\n", [httpResponse statusCode], [[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] capitalizedString]];
    
//    [headersTab setLabel:[NSString stringWithFormat:@"Response Headers (%ld)", [httpResponse statusCode]]];
	
	NSDictionary *headerDict = [httpResponse allHeaderFields];
//    contentType = nil;
	for (NSString *key in headerDict) {
		[headers appendFormat:@"%@: %@\n", key, [headerDict objectForKey:key]];
		if ([key isEqualToString:@"Content-Type"]) {
			NSString *contentTypeLine = [headerDict objectForKey:key];
			NSArray *parts = [contentTypeLine componentsSeparatedByString:@";"];
//			contentType = [[NSString alloc] initWithString:[parts objectAtIndex:0]];
            if ([parts count] > 1) {
//                charset = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"charset=" withString:@""];
            }
//			NSLog(@"Got content type = %@", contentType);
		}
	}
	
//    self.responseView.syntaxMIME = contentType;
    self.responseHeadersTextView.string = headers;
}

@end
