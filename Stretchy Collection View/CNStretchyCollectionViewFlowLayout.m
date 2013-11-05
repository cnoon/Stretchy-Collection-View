//
//  CNStretchyCollectionViewFlowLayout.m
//  CNSpringCollectionView
//
//  Created by Christian Noon on 11/3/13.
//  Copyright (c) 2013 NoonDev. All rights reserved.
//

#import "CNStretchyCollectionViewFlowLayout.h"

#pragma mark -

@interface CNStretchyCollectionViewFlowLayout ()

- (CGSize)collectionViewContentSizeWithoutOverflow;

@end

#pragma mark -

@implementation CNStretchyCollectionViewFlowLayout
{
	BOOL			_transformsNeedReset;
	CGFloat			_scrollResistanceDenominator;
	UIEdgeInsets	_contentOverflowPadding;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		// Set up the flow layout parameters
		self.minimumInteritemSpacing = 10;
		self.minimumLineSpacing = 10;
		self.itemSize = CGSizeMake(320, 44);
		self.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);

		// Set up ivars
		_transformsNeedReset = NO;
		_scrollResistanceDenominator = 800.0f;
		_contentOverflowPadding = UIEdgeInsetsMake(100.0f, 0.0f, 100.0f, 0.0f);
		_bufferedContentInsets = _contentOverflowPadding;
		_bufferedContentInsets.top *= -1;
		_bufferedContentInsets.bottom *= -1;
	}

	return self;
}

- (void)prepareLayout
{
	[super prepareLayout];
}

- (CGSize)collectionViewContentSize
{
	CGSize contentSize = [super collectionViewContentSize];
	contentSize.height += _contentOverflowPadding.top + _contentOverflowPadding.bottom;
	return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	// Set up the default attributes using the parent implementation (need to adjust the rect to account for buffer spacing)
	rect = UIEdgeInsetsInsetRect(rect, _bufferedContentInsets);
	NSArray *items = [super layoutAttributesForElementsInRect:rect];

	// Shift all the items down due to the content overflow padding
	for (UICollectionViewLayoutAttributes *item in items)
	{
		CGPoint center = item.center;
		center.y += _contentOverflowPadding.top;
		item.center = center;
	}

	// Compute whether we need to adjust the transforms on the cells
	CGFloat collectionViewHeight = [self collectionViewContentSizeWithoutOverflow].height;
	CGFloat topOffset = _contentOverflowPadding.top;
	CGFloat bottomOffset = collectionViewHeight - self.collectionView.frame.size.height + _contentOverflowPadding.top;
	CGFloat yPosition = self.collectionView.contentOffset.y;

	// Update the transforms if necessary
	if (yPosition < topOffset)
	{
		// Compute the stretch delta
		CGFloat stretchDelta = topOffset - yPosition;
		NSLog(@"Stretching Top by: %f", stretchDelta);

		// Iterate through all the visible items for the new bounds and update the transform
		for (UICollectionViewLayoutAttributes *item in items)
		{
			CGFloat distanceFromTop = item.center.y - _contentOverflowPadding.top;
			CGFloat scrollResistance = distanceFromTop / _scrollResistanceDenominator;
			item.transform = CGAffineTransformMakeTranslation(0, -stretchDelta + (stretchDelta * scrollResistance));
		}

		// Update the ivar for requiring a reset
		_transformsNeedReset = YES;
	}
	else if (yPosition > bottomOffset)
	{
		// Compute the stretch delta
		CGFloat stretchDelta = yPosition - bottomOffset;
		NSLog(@"Stretching bottom by: %f", stretchDelta);

		// Iterate through all the visible items for the new bounds and update the transform
		for (UICollectionViewLayoutAttributes *item in items)
		{
			CGFloat distanceFromBottom = collectionViewHeight + _contentOverflowPadding.top - item.center.y;
			CGFloat scrollResistance = distanceFromBottom / _scrollResistanceDenominator;
			item.transform = CGAffineTransformMakeTranslation(0, stretchDelta + (-stretchDelta * scrollResistance));
		}

		// Update the ivar for requiring a reset
		_transformsNeedReset = YES;
	}
	else if (_transformsNeedReset)
	{
		NSLog(@"Resetting transforms");
		_transformsNeedReset = NO;
		for (UICollectionViewLayoutAttributes *item in items)
			item.transform = CGAffineTransformIdentity;
	}

	return items;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

#pragma mark - Private Methods

- (CGSize)collectionViewContentSizeWithoutOverflow
{
	return [super collectionViewContentSize];
}

@end
