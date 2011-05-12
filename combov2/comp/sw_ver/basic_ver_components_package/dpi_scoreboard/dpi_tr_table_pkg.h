/* MTI_DPI */

/*
 * Copyright 2002-2010 Mentor Graphics Corporation.
 *
 * Note:
 *   This file is automatically generated.
 *   Please do not edit this file - you will lose your edits.
 *
 * Settings when this file was generated:
 *   PLATFORM = 'linux_x86_64'
 */
#ifndef INCLUDED_DPI_TR_TABLE_PKG
#define INCLUDED_DPI_TR_TABLE_PKG

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"


DPI_LINK_DECL DPI_DLLESPEC
void
c_addToTable(
    const svOpenArrayHandle inTrans);

DPI_LINK_DECL DPI_DLLESPEC
void
c_displayTable();

DPI_LINK_DECL DPI_DLLESPEC
int
c_removeFromTable(
    const svOpenArrayHandle outTrans);

#endif 