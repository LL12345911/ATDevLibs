//
//  UITableView+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/4.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UITableView+ATKit.h"
#import <objc/runtime.h>
#import "UIKitLibDefine.h"

ATSYNTH_DUMMY_CLASS(UITableView_ATKit)


@implementation UITableView (ATKit)

-(void)reloadDataWithCompletion:(void(^)(void))completion{
    if (!completion) {
        [self reloadData];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)showPlaceHolderView{
    if (self.placeHolderView && !self.placeHolderView.superview) {
        [self addSubview:self.placeHolderView];
    }
}

-(void)hidePlaceHolderView{
    if (self.placeHolderView && self.placeHolderView.superview) {
        [self.placeHolderView removeFromSuperview];
    }
}

-(void)reloadDataAndHandlePlaceHolderView{
    __weak typeof(self)weakSelf = self;
    [self reloadDataWithCompletion:^{
        if ([weakSelf calculateHasData]) {
            [weakSelf hidePlaceHolderView];
        } else {
            [weakSelf showPlaceHolderView];
        }
    }];
}

-(BOOL)calculateHasData{
    return [self at_TotalItems] > 0 ? YES : NO;
}

-(void)setPlaceHolderView:(UIView *)placeHolderView{
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)placeHolderView{
    return objc_getAssociatedObject(self, _cmd);
}

-(NSInteger)at_DistanceBetweenIndexPathA:(NSIndexPath *)idxPA indexPathB:(NSIndexPath *)idxPB {
    if (self.dataSource == nil) {
        NSAssert(NO, @"you dataSource is nil so we can't calculate the distance.");
        return -1;
    }
    if (![self at_IsValidIndexPath:idxPA] || ![self at_IsValidIndexPath:idxPB]) {
        NSAssert(NO, @"the indexPath you sent is not valid.you should check them.");
        return -1;
    }
    if ([idxPA isEqual:idxPB]) {
        return 0;
    }
    NSInteger sectionDelta = idxPB.section - idxPA.section;
    if (sectionDelta > 0) {
        return [self calculateDistanceWithLessSectionIdxP:idxPA greaterSectionIdxP:idxPB];
    } else if (sectionDelta < 0) {
        return [self calculateDistanceWithLessSectionIdxP:idxPB greaterSectionIdxP:idxPA];
    } else {
        return labs(idxPA.row - idxPB.row);
    }
}

-(BOOL)at_IsValidIndexPath:(NSIndexPath *)idxP {
    if (self.dataSource == nil) {
        NSAssert(NO, @"you dataSource is nil so we can't calculate the distance.");
        return NO;
    }
    if (idxP.section >= self.numberOfSections) {
        return NO;
    }
    if (idxP.row >= [self numberOfRowsInSection:idxP.section]) {
        return NO;
    }
    return YES;
}

-(NSUInteger)calculateDistanceWithLessSectionIdxP:(NSIndexPath *)idxPA greaterSectionIdxP:(NSIndexPath *)idxPB {
    NSUInteger distance = 0;
    NSInteger row = idxPA.row + 1;
    NSInteger section = idxPA.section;
    while (section < idxPB.section) {
        distance += ([self numberOfRowsInSection:section]) - row;
        section ++;
        row = 0;
    }
    distance += (idxPB.row + 1);
    return distance;
}

-(NSUInteger)at_TotalItems {
    NSInteger sections = self.numberOfSections;
    NSInteger itemsCount = 0;
    for (int i = 0; i < sections; i++) {
        itemsCount += [self numberOfRowsInSection:i];
    }
    return itemsCount;
}

-(NSArray <NSIndexPath *>*)at_IndexPathsAroundIndexPath:(NSIndexPath *)idxP nextOrPreivious:(BOOL)isNext count:(NSUInteger)count step:(NSInteger)step {
    
    if (count == 0) {
        return nil;
    }
    
    if (step > [self at_TotalItems]) {
        return nil;
    }
    
    if (step < 1) {
        step = 1;
    }
    
    NSInteger section = idxP.section;
    NSInteger row = idxP.row;
    section = section < self.numberOfSections ? section :self.numberOfSections;
    row = row <= [self numberOfRowsInSection:section] ? row :[self numberOfRowsInSection:section];
    
    NSInteger fator = isNext ? 1 : -1;
    
    NSMutableArray * arr = [NSMutableArray array];
    do {
        row += step * fator;
        if (row >= 0 && row < [self numberOfRowsInSection:section]) {
            [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        } else {
        HandleSection:
            section += fator;
            if (section < 0 || section >= self.numberOfSections) {
                break;
            } else {
                if (row < 0) {
                    row += [self numberOfRowsInSection:section];
                    if (row < 0) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                } else {
                    row -= [self numberOfRowsInSection:section - 1];
                    if (row >= [self numberOfRowsInSection:section]) {
                        goto HandleSection;
                    } else {
                        [arr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                }
            }
        }
    } while (arr.count < count);
    return arr.copy;
}













- (void)updateWithBlock:(void (^)(UITableView *tableView))block {
    [self beginUpdates];
    block(self);
    [self endUpdates];
}

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toInsert = [NSIndexPath indexPathForRow:row inSection:section];
    [self insertRowAtIndexPath:toInsert withRowAnimation:animation];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toReload = [NSIndexPath indexPathForRow:row inSection:section];
    [self reloadRowAtIndexPath:toReload withRowAnimation:animation];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toDelete = [NSIndexPath indexPathForRow:row inSection:section];
    [self deleteRowAtIndexPath:toDelete withRowAnimation:animation];
}

- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self insertSections:sections withRowAnimation:animation];
}

- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self deleteSections:sections withRowAnimation:animation];
}

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:indexSet withRowAnimation:animation];
}

- (void)clearSelectedRowsAnimated:(BOOL)animated {
    NSArray *indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath* path, NSUInteger idx, BOOL *stop) {
        [self deselectRowAtIndexPath:path animated:animated];
    }];
}


@end
