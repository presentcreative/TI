#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "chipmunk.h"
#include "march.h"

static inline void
seg(cpVect v0, cpVect v1, segment_func f, void *data)
{
	if(!cpveq(v0, v1)) f(v0, v1, data);
}

static inline cpFloat
mid(cpFloat a, cpFloat b, cpFloat t){
	return (t - a)/(b - a);
}

void
march_soft(
  int x1, int y1, int x2, int y2, cpFloat t,
  segment_func segment, void *segment_data,
  sampling_func sample, void *sample_data
){
	for(int y=y1; y<y2 - 1; y++){
		cpFloat a, b = sample(x1, y  , sample_data);
		cpFloat c, d = sample(x1, y+1, sample_data);
		
		for(int x=x1; x<x2 - 1; x++){
      a = b, b = sample(x+1, y  , sample_data);
      c = d, d = sample(x+1, y+1, sample_data);
      
      cpFloat X0 = x, X1 = X0 + 1.0;
      cpFloat Y0 = y, Y1 = Y0 + 1.0;
      
      switch((a>t)<<0 | (b>t)<<1 | (c>t)<<2 | (d>t)<<3){
        case 0x1: seg(cpv(X0, Y0 + mid(a,c,t)), cpv(X0 + mid(a,b,t), Y0), segment, segment_data); continue;
        case 0x2: seg(cpv(X0 + mid(a,b,t), Y0), cpv(X1, Y0 + mid(b,d,t)), segment, segment_data); continue;
        case 0x3: seg(cpv(X0, Y0 + mid(a,c,t)), cpv(X1, Y0 + mid(b,d,t)), segment, segment_data); continue;
        case 0x4: seg(cpv(X0 + mid(c,d,t), Y1), cpv(X0, Y0 + mid(a,c,t)), segment, segment_data); continue;
        case 0x5: seg(cpv(X0 + mid(c,d,t), Y1), cpv(X0 + mid(a,b,t), Y0), segment, segment_data); continue;
        case 0x6:
          seg(cpv(X0 + mid(a,b,t), Y0), cpv(X1, Y0 + mid(b,d,t)), segment, segment_data); // 0x2
          seg(cpv(X0 + mid(c,d,t), Y1), cpv(X0, Y0 + mid(a,c,t)), segment, segment_data); // 0x4
          continue;
        case 0x7: seg(cpv(X0 + mid(c,d,t), Y1), cpv(X1, Y0 + mid(b,d,t)), segment, segment_data); continue;
        case 0x8: seg(cpv(X1, Y0 + mid(b,d,t)), cpv(X0 + mid(c,d,t), Y1), segment, segment_data); continue;
        case 0x9:
          seg(cpv(X0, Y0 + mid(a,c,t)), cpv(X0 + mid(a,b,t), Y0), segment, segment_data); // 0x1
          seg(cpv(X1, Y0 + mid(b,d,t)), cpv(X0 + mid(c,d,t), Y1), segment, segment_data); // 0x8
          continue;
        case 0xA: seg(cpv(X0 + mid(a,b,t), Y0), cpv(X0 + mid(c,d,t), Y1), segment, segment_data); continue;
        case 0xB: seg(cpv(X0, Y0 + mid(a,c,t)), cpv(X0 + mid(c,d,t), Y1), segment, segment_data); continue;
        case 0xC: seg(cpv(X1, Y0 + mid(b,d,t)), cpv(X0, Y0 + mid(a,c,t)), segment, segment_data); continue;
        case 0xD: seg(cpv(X1, Y0 + mid(b,d,t)), cpv(X0 + mid(a,b,t), Y0), segment, segment_data); continue;
        case 0xE: seg(cpv(X0 + mid(a,b,t), Y0), cpv(X0, Y0 + mid(a,c,t)), segment, segment_data); continue;
        default: continue; // 0x0 and 0xF
      }
		}
	}
}

static inline void
segs(cpVect a, cpVect b, cpVect c, segment_func f, void *data)
{
	seg(a, b, f, data);
	seg(b, c, f, data);
}

void
march_hard(
  int x1, int y1, int x2, int y2, cpFloat t,
  segment_func segment, void *segment_data,
  sampling_func sample, void *sample_data
){
	for(int y=y1; y<y2 - 1; y++){
		cpFloat a, b = sample(x1, y  , sample_data);
		cpFloat c, d = sample(x1, y+1, sample_data);
		
		for(int x=x1; x<x2 - 1; x++){
      a = b, b = sample(x+1, y  , sample_data);
      c = d, d = sample(x+1, y+1, sample_data);
      
      cpFloat X0 = x, X12 = X0 + 0.5, X1 = X0 + 1.0;
      cpFloat Y0 = y, Y12 = Y0 + 0.5, Y1 = Y0 + 1.0;
      
      switch((a>t)<<0 | (b>t)<<1 | (c>t)<<2 | (d>t)<<3){
        case 0x1: segs(cpv(X0, Y12), cpv(X12, Y12), cpv(X12, Y0), segment, segment_data); continue;
        case 0x2: segs(cpv(X12, Y0), cpv(X12, Y12), cpv(X1, Y12), segment, segment_data); continue;
        case 0x3: seg(cpv(X0, Y12), cpv(X1, Y12), segment, segment_data); continue;
        case 0x4: segs(cpv(X12, Y1), cpv(X12, Y12), cpv(X0, Y12), segment, segment_data); continue;
        case 0x5: seg(cpv(X12, Y1), cpv(X12, Y0), segment, segment_data); continue;
        case 0x6: // 0x2 and 0x4
          segs(cpv(X12, Y0), cpv(X12, Y12), cpv(X0, Y12), segment, segment_data);
          segs(cpv(X12, Y1), cpv(X12, Y12), cpv(X1, Y12), segment, segment_data);
          continue;
        case 0x7: segs(cpv(X12, Y1), cpv(X12, Y12), cpv(X1, Y12), segment,segment_data); continue;
        case 0x8: segs(cpv(X1, Y12), cpv(X12, Y12), cpv(X12, Y1), segment, segment_data); continue;
        case 0x9: // 0x1 and 0x8
          segs(cpv(X1, Y12), cpv(X12, Y12), cpv(X12, Y0), segment, segment_data);
          segs(cpv(X0, Y12), cpv(X12, Y12), cpv(X12, Y1), segment, segment_data);
          continue;
        case 0xA: seg(cpv(X12, Y0), cpv(X12, Y1), segment, segment_data); continue;
        case 0xB: segs(cpv(X0, Y12), cpv(X12, Y12), cpv(X12, Y1), segment, segment_data); continue;
        case 0xC: seg(cpv(X1, Y12), cpv(X0, Y12), segment, segment_data); continue;
        case 0xD: segs(cpv(X1, Y12), cpv(X12, Y12), cpv(X12, Y0), segment, segment_data); continue;
        case 0xE: segs(cpv(X12, Y0), cpv(X12, Y12), cpv(X0, Y12), segment, segment_data); continue;
        default: continue; // 0x0 and 0xF
      }
		}
	}
}
