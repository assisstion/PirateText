//
//  PirateConverter.m
//  PirateText
//
//  Created by Markus Feng on 9/30/15.
//  Copyright © 2015 Markus Feng. All rights reserved.
//

#import "PirateConverter.h"

@implementation PirateConverter

-(id)init{
    if(self != nil){
        [self setupDictionary];
    }
    return self;
}

-(void)setupDictionary{
    //Sets up the dictionary that converts English to Pirate language
    _dictionary = @{
                    @"hello" : @"ahoy",
                    @"pardon me" : @"avast",
                    @"excuse me" : @"arrr",
                    @"sir" : @"matey",
                    @"madam" : @"proud beauty",
                    @"miss" : @"comely wench",
                    @"stranger" : @"scurvy dog",
                    @"officer" : @"foul blaggart",
                    @"where is" : @"whar be",
                    @"can you help me find" : @"know ye",
                    @"is that" : @"be that",
                    @"how far is it to" : @"how many leagues to",
                    @"the" : @"th’",
                    @"a" : @"a briny",
                    @"any" : @"some forsaken",
                    @"nearby" : @"broadside",
                    @"my" : @"me",
                    @"your" : @"yer",
                    @"old" : @"barnacle-covered",
                    @"attractive" : @"comely",
                    @"happy" : @"grog-filled",
                    @"restaurant" : @"galley",
                    @"hotel" : @"fleabag inn",
                    @"mall" : @"market",
                    @"pub" : @"Skull & Scuppers",
                    @"bank" : @"buried treasure",
                    @"I would like to" : @"I be needin’ t’",
                    @"I desire" : @"I've a fierce fire in me belly t'",
                    @"I wish I knew how to" : @"I be hankerin' t'",
                    @"my mother told me to" : @"me dear ol' mum, bless her  soul, tol' me t'",
                    @"my companion would like to" : @"me mate, ol' Rumpot, wants t'",
                    @"find" : @"come across",
                    @"take a nap" : @"have a bit of a lie-down",
                    @"make a withdrawal" : @"seize all me gold",
                    @"have a cocktail" : @"swill a pint or two o' grog"
                    };
}

-(NSString *)convertFromEnglishToPirate: (NSString *) input{
    NSString * output = [self removeFromString:input theCharacters:@"`|"];
    output = [self escapePhrasesWithCapitalLetters:output];
    NSArray * keysMultiWordBeforeSingleWord = [self sortDictionaryKeysIntoMultiWordBeforeSingleWord: _dictionary];
    NSMutableDictionary * placeholderDict = [[NSMutableDictionary alloc] init];
    output = [self replaceMatchesInInputWithPlaceholders:output withPlaceholderDictionary:placeholderDict loopingThroughDictionaryKeys:keysMultiWordBeforeSingleWord];
    output = [self replacePlaceholdersWithTranslatedWords:output withPlaceholderDictionary: placeholderDict];
    output = [self unescapePhrasesWithCapitalLetters:output];
    return output;
}

-(NSString *) removeFromString: (NSString *) input theCharacters: (NSString *) removed{
    NSCharacterSet * notAllowed = [NSCharacterSet characterSetWithCharactersInString:removed];
    NSArray * parts = [input componentsSeparatedByCharactersInSet:notAllowed];
    NSString * output = [parts componentsJoinedByString:@""];
    return output;
}

-(NSString *) escapePhrasesWithCapitalLetters: (NSString *) input{
    NSMutableString * output = [input mutableCopy];
    mutableStringOffset = 0;
    //Creates a regular expression of a word beginning with a capital letter
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:@"\\b([A-Z])([A-Za-z]*)\\b" options:0 error:nil];
    [regex enumerateMatchesInString:input options:0 range:NSMakeRange(0, input.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        //For each match of the regular expression, process it and apply the changes to the mutable string
        [self processEscapedMatchWithInput:input andResult:result andOutput: output];
    }];
    return [[NSString alloc] initWithString:output];
}

-(void)processEscapedMatchWithInput:(NSString *)input andResult:(NSTextCheckingResult *)result andOutput: (NSMutableString *) mut{
    NSRange capitalLetterRange = [result rangeAtIndex:1];
    NSRange remainderOfWordRange = [result rangeAtIndex:2];
    NSRange entireWordRange = NSMakeRange(capitalLetterRange.location,
        remainderOfWordRange.length + 1);
    bool inputShouldBeEscaped = false;
    NSString * matchedInput = [input substringWithRange:entireWordRange];
    //If no key starts with the word that begins with a capital letter, skip the word
    for(NSString * key in [_dictionary keyEnumerator]){
        if([self firstStringBeginsWithSecondStringWithFirstString:key andSecondString:matchedInput]){
            inputShouldBeEscaped = true;
            break;
        }
    }
    if(inputShouldBeEscaped){
        NSRange letterInMutableStringRange = NSMakeRange(capitalLetterRange.location
            + mutableStringOffset, capitalLetterRange.length);
        //Add a | to the word beginning with a capital letter
        [mut replaceCharactersInRange:letterInMutableStringRange withString:[@"|" stringByAppendingString:[input substringWithRange:capitalLetterRange]]];
        //Increases the index of all following matches of the mutable string
        //by onebecause one character was added to the mutable string
        mutableStringOffset++;
    }
}

-(bool)firstStringBeginsWithSecondStringWithFirstString:(NSString *)firstString andSecondString: (NSString *) secondString{
    //Creates a regular expression of the matched word
    //to see if any key in the dictionary starts with that word
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern: [@"^" stringByAppendingString:secondString] options:NSRegularExpressionCaseInsensitive error:nil];
    if([regex numberOfMatchesInString:firstString options:0 range:NSMakeRange(0, firstString.length)] > 0){
        return true;
    }
    return false;
}

-(NSString *)replaceMatchesInInputWithPlaceholders: (NSString *)input withPlaceholderDictionary: (NSMutableDictionary*) placeholderDict loopingThroughDictionaryKeys: (NSArray *) dictionaryKeys{
    
    //Makes the placeholder key counter start at 10000 so all keys have 5 numerical digits (up to 89999 keys)
    int counter = 10000;
    
    NSString * output = input;
    
    for(NSString * key in dictionaryKeys){
        //Add regex word separators to the English word
        NSString * keyByWord = [NSString stringWithFormat:@"\\b%@\\b", key];
        //The Pirate word that corresponds the the English word
        NSString * value = [_dictionary objectForKey:key];
        //Creates a regular expression that looks for the English word
        //with regex word separators
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:keyByWord options:NSRegularExpressionCaseInsensitive error:nil];
        //Creates a temporary key that is put into the temporary
        //dictionary store phrases that have been converted
        NSString * placeholderKey = [@"`" stringByAppendingString: [NSString stringWithFormat:@"%i", counter]];
        counter++;
        //Add the to be replaced word into a dictionary to prevent reconverting,
        //putting a key beginning with ` to replace later
        [placeholderDict setObject:value forKey:placeholderKey];
        //Searches matches to the word with the regular expression
        //and replaces the matches with the temporary key beginning with `
        output = [regex stringByReplacingMatchesInString:output options:0 range:NSMakeRange(0, output.length) withTemplate:placeholderKey];
    }
    
    return output;
}

-(NSString *)replacePlaceholdersWithTranslatedWords: (NSString *)input withPlaceholderDictionary: (NSMutableDictionary *) tempDict{
    NSString * output = input;
    for(NSString * tempKey in [tempDict keyEnumerator]){
        output = [output stringByReplacingOccurrencesOfString:tempKey withString:[tempDict objectForKey:tempKey]];
    }
    return output;
}

-(NSArray *)sortDictionaryKeysIntoMultiWordBeforeSingleWord: (NSDictionary *) dict{
    NSPredicate * doesContainSpace = [NSPredicate predicateWithFormat:@"self CONTAINS ' '"];
    NSArray * multi = [_dictionary.allKeys filteredArrayUsingPredicate: doesContainSpace];
    NSPredicate * doesNotContainSpace = [NSPredicate predicateWithFormat:@"NOT self CONTAINS ' '"];
    NSArray * single = [_dictionary.allKeys filteredArrayUsingPredicate: doesNotContainSpace];
    NSArray * multiBeforeSingle = [multi arrayByAddingObjectsFromArray:single];
    return multiBeforeSingle;
}


-(NSString *) unescapePhrasesWithCapitalLetters: (NSString *) input{
    NSMutableString * output = [input mutableCopy];
    mutableStringOffset = 0;
    //Creates a regular expression that matches all words beginning with a |
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:@"\\|([A-Za-z])" options:0 error:nil];
    [regex enumerateMatchesInString:input options:0 range:NSMakeRange(0, input.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        //For each match of the regular expression, process it and apply the changes to the mutable string:
        [self processUnescapingMatchWithInput:input andResult:result andOutput:output];
    }];
    return [[NSString alloc] initWithString:output];
}

-(void)processUnescapingMatchWithInput: (NSString *)input andResult: (NSTextCheckingResult *) result andOutput: (NSMutableString *) mut{
    //Finds the location of the capital letter in the input string
    NSRange range = [result rangeAtIndex:1];
    //Finds the range of the letter with the | in the mutable string
    NSRange modRange = NSMakeRange(range.location + mutableStringOffset - 1, range.length + 1);
    //Capitalize the word beginning with a | and remove the |
    [mut replaceCharactersInRange:modRange withString:[[input substringWithRange:range] uppercaseString]];
    //Reduces the index of all following matches of the mutable string
    //by one because one character was removed from the mutable string
    mutableStringOffset--;
}
@end
