/**
 * 手势识别器
 * 识别点击、长按、滑动等手势
 * 参考scrcpy的手势处理逻辑
 */

export default class GestureRecognizer {
  constructor(options = {}) {
    // 配置参数
    this.config = {
      longPressDelay: options.longPressDelay || 500,      // 长按延迟（毫秒）
      clickThreshold: options.clickThreshold || 10,        // 点击移动阈值（像素）
      swipeThreshold: options.swipeThreshold || 20,        // 滑动最小距离（像素）
      doubleTapDelay: options.doubleTapDelay || 300,       // 双击间隔（毫秒）
      moveThrottleDelay: options.moveThrottleDelay || 16   // 移动事件节流（毫秒，约60fps）
    };

    // 手势状态
    this.state = {
      isPressed: false,
      startX: 0,
      startY: 0,
      currentX: 0,
      currentY: 0,
      startTime: 0,
      lastMoveTime: 0,
      longPressTimer: null,
      longPressTriggered: false,
      lastTapTime: 0,
      tapCount: 0
    };

    // 手势路径（用于滑动）
    this.gesturePath = [];
  }

  /**
   * 开始手势（鼠标按下或触摸开始）
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {string} pointerType - 指针类型 ('mouse' | 'touch' | 'pen')
   * @returns {{type: string, data: object}}
   */
  start(x, y, pointerType = 'mouse') {
    this.state.isPressed = true;
    this.state.startX = x;
    this.state.startY = y;
    this.state.currentX = x;
    this.state.currentY = y;
    this.state.startTime = Date.now();
    this.state.lastMoveTime = this.state.startTime;
    this.state.longPressTriggered = false;

    // 清空手势路径
    this.gesturePath = [{ x, y, time: this.state.startTime }];

    // 启动长按定时器
    this.startLongPressTimer();

    // 检测双击
    const now = Date.now();
    if (now - this.state.lastTapTime < this.config.doubleTapDelay) {
      this.state.tapCount++;
    } else {
      this.state.tapCount = 1;
    }

    return {
      type: 'press',
      data: {
        x,
        y,
        pointerType,
        timestamp: this.state.startTime
      }
    };
  }

  /**
   * 移动手势
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @returns {{type: string, data: object} | null}
   */
  move(x, y) {
    if (!this.state.isPressed) {
      return null;
    }

    const now = Date.now();
    
    // 节流：限制移动事件频率
    if (now - this.state.lastMoveTime < this.config.moveThrottleDelay) {
      return null;
    }

    this.state.currentX = x;
    this.state.currentY = y;
    this.state.lastMoveTime = now;

    // 添加到手势路径
    this.gesturePath.push({ x, y, time: now });

    // 计算移动距离
    const distance = this.calculateDistance(
      this.state.startX,
      this.state.startY,
      x,
      y
    );

    // 如果移动超过阈值，取消长按
    if (distance > this.config.clickThreshold) {
      this.cancelLongPress();
    }

    return {
      type: 'move',
      data: {
        x,
        y,
        startX: this.state.startX,
        startY: this.state.startY,
        distance,
        timestamp: now
      }
    };
  }

  /**
   * 结束手势（鼠标释放或触摸结束）
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @returns {{type: string, data: object}}
   */
  end(x, y) {
    if (!this.state.isPressed) {
      return { type: 'none', data: {} };
    }

    const endTime = Date.now();
    const duration = endTime - this.state.startTime;
    const distance = this.calculateDistance(
      this.state.startX,
      this.state.startY,
      x,
      y
    );

    // 取消长按定时器
    this.cancelLongPress();

    this.state.isPressed = false;
    this.state.lastTapTime = endTime;

    // 判断手势类型
    let gestureType;
    let gestureData;

    if (this.state.longPressTriggered) {
      // 长按
      gestureType = 'longPress';
      gestureData = {
        x: this.state.startX,
        y: this.state.startY,
        duration
      };
    } else if (distance < this.config.clickThreshold) {
      // 点击或双击
      if (this.state.tapCount >= 2) {
        gestureType = 'doubleTap';
        this.state.tapCount = 0;
      } else {
        gestureType = 'tap';
      }
      gestureData = {
        x: this.state.startX,
        y: this.state.startY,
        tapCount: this.state.tapCount
      };
    } else if (distance >= this.config.swipeThreshold) {
      // 滑动
      gestureType = 'swipe';
      gestureData = {
        startX: this.state.startX,
        startY: this.state.startY,
        endX: x,
        endY: y,
        distance,
        duration,
        path: this.gesturePath,
        velocity: this.calculateVelocity()
      };
    } else {
      // 移动距离太小，视为点击
      gestureType = 'tap';
      gestureData = {
        x: this.state.startX,
        y: this.state.startY
      };
    }

    return {
      type: gestureType,
      data: gestureData
    };
  }

  /**
   * 取消手势
   */
  cancel() {
    this.cancelLongPress();
    this.state.isPressed = false;
    this.gesturePath = [];
    
    return {
      type: 'cancel',
      data: {}
    };
  }

  /**
   * 启动长按定时器
   */
  startLongPressTimer() {
    this.cancelLongPress();
    
    this.state.longPressTimer = setTimeout(() => {
      if (this.state.isPressed && !this.state.longPressTriggered) {
        this.state.longPressTriggered = true;
        
        // 触发长按回调（如果有）
        if (this.onLongPress) {
          this.onLongPress({
            x: this.state.startX,
            y: this.state.startY,
            duration: Date.now() - this.state.startTime
          });
        }
      }
    }, this.config.longPressDelay);
  }

  /**
   * 取消长按定时器
   */
  cancelLongPress() {
    if (this.state.longPressTimer) {
      clearTimeout(this.state.longPressTimer);
      this.state.longPressTimer = null;
    }
  }

  /**
   * 计算两点之间的距离
   */
  calculateDistance(x1, y1, x2, y2) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /**
   * 计算滑动速度
   * @returns {{x: number, y: number, magnitude: number}}
   */
  calculateVelocity() {
    if (this.gesturePath.length < 2) {
      return { x: 0, y: 0, magnitude: 0 };
    }

    // 使用最后几个点计算速度
    const sampleSize = Math.min(5, this.gesturePath.length);
    const recentPoints = this.gesturePath.slice(-sampleSize);
    
    const first = recentPoints[0];
    const last = recentPoints[recentPoints.length - 1];
    
    const dx = last.x - first.x;
    const dy = last.y - first.y;
    const dt = (last.time - first.time) / 1000; // 转换为秒

    if (dt === 0) {
      return { x: 0, y: 0, magnitude: 0 };
    }

    const vx = dx / dt;
    const vy = dy / dt;
    const magnitude = Math.sqrt(vx * vx + vy * vy);

    return { x: vx, y: vy, magnitude };
  }

  /**
   * 获取滑动方向
   * @returns {'up' | 'down' | 'left' | 'right' | 'none'}
   */
  getSwipeDirection() {
    if (this.gesturePath.length < 2) {
      return 'none';
    }

    const first = this.gesturePath[0];
    const last = this.gesturePath[this.gesturePath.length - 1];

    const dx = last.x - first.x;
    const dy = last.y - first.y;

    if (Math.abs(dx) > Math.abs(dy)) {
      return dx > 0 ? 'right' : 'left';
    } else {
      return dy > 0 ? 'down' : 'up';
    }
  }

  /**
   * 简化手势路径（用于减少数据传输）
   * 使用Douglas-Peucker算法简化路径
   * @param {number} tolerance - 容差值
   * @returns {Array}
   */
  simplifyPath(tolerance = 5) {
    if (this.gesturePath.length <= 2) {
      return this.gesturePath;
    }

    return this.douglasPeucker(this.gesturePath, tolerance);
  }

  /**
   * Douglas-Peucker路径简化算法
   */
  douglasPeucker(points, tolerance) {
    if (points.length <= 2) {
      return points;
    }

    // 找到距离起点和终点连线最远的点
    let maxDistance = 0;
    let maxIndex = 0;
    const first = points[0];
    const last = points[points.length - 1];

    for (let i = 1; i < points.length - 1; i++) {
      const distance = this.perpendicularDistance(points[i], first, last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // 如果最大距离大于容差，递归简化
    if (maxDistance > tolerance) {
      const left = this.douglasPeucker(points.slice(0, maxIndex + 1), tolerance);
      const right = this.douglasPeucker(points.slice(maxIndex), tolerance);
      return left.slice(0, -1).concat(right);
    } else {
      return [first, last];
    }
  }

  /**
   * 计算点到线段的垂直距离
   */
  perpendicularDistance(point, lineStart, lineEnd) {
    const dx = lineEnd.x - lineStart.x;
    const dy = lineEnd.y - lineStart.y;
    
    if (dx === 0 && dy === 0) {
      return this.calculateDistance(point.x, point.y, lineStart.x, lineStart.y);
    }

    const t = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / (dx * dx + dy * dy);
    
    if (t < 0) {
      return this.calculateDistance(point.x, point.y, lineStart.x, lineStart.y);
    } else if (t > 1) {
      return this.calculateDistance(point.x, point.y, lineEnd.x, lineEnd.y);
    }

    const projX = lineStart.x + t * dx;
    const projY = lineStart.y + t * dy;
    
    return this.calculateDistance(point.x, point.y, projX, projY);
  }

  /**
   * 重置手势识别器
   */
  reset() {
    this.cancel();
    this.state.tapCount = 0;
    this.state.lastTapTime = 0;
  }
}
